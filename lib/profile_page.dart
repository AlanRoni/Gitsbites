import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource;
import 'package:firebase_storage/firebase_storage.dart';
import 'bottom_nav.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;
  File? _profilePicFile;

  // Fetch the user data from Firebase Auth and Firestore
  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc['profilePicUrl'] != null) {
        setState(() {
          _profilePicFile = null;
        });
      }
    }
  }

  // Save the edited profile information to Firestore and update Auth details
  Future<void> _saveProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        String? profilePicUrl;
        if (_profilePicFile != null) {
          final storageRef =
              _storage.ref().child('profile_pics/${user.uid}.jpg');
          final uploadTask = storageRef.putFile(_profilePicFile!);
          final snapshot = await uploadTask;
          profilePicUrl = await snapshot.ref.getDownloadURL();
        }

        await user.updateDisplayName(_nameController.text);

        await _firestore.collection('users').doc(user.uid).set({
          'name': _nameController.text,
          'email': _emailController.text,
          'profilePicUrl': profilePicUrl,
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  // Select a new profile picture from the gallery
  Future<void> _pickProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profilePicFile = File(pickedFile.path);
      });
    }
  }

  // Submit review to Firestore
  Future<void> _submitReview() async {
    final user = _auth.currentUser;
    if (user != null && _reviewController.text.isNotEmpty) {
      try {
        await _firestore.collection('reviews').add({
          'userId': user.uid,
          'name': user.displayName ??
              'Anonymous', // If name is null, use 'Anonymous'
          'email': user.email ?? 'No email', // If email is null, use 'No email'
          'review': _reviewController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully!')),
        );
        _reviewController.clear(); // Clear review text
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data on page load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text(
              'Profile',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.person_outline,
              size: 24,
              color: Colors.white,
            ),
          ],
        ),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Background Gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Color(0xFFA8D5A3)], // Gradient colors
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Profile Content
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Picture and Name
                    GestureDetector(
                      onTap: _pickProfilePicture,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _profilePicFile != null
                            ? FileImage(_profilePicFile!)
                            : const AssetImage('assets/profile_pic.png')
                                as ImageProvider,
                        backgroundColor: Colors.grey[200],
                        child: _profilePicFile == null
                            ? const Icon(Icons.camera_alt, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _isEditing
                        ? TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              hintText: 'Enter your name',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 16.0),
                            ),
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )
                        : Text(
                            _nameController.text.isEmpty
                                ? 'Your Name'
                                : _nameController.text,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    const SizedBox(height: 5),
                    Text(
                      _emailController.text,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 20),
// Profile options list with simplified order fetching (no email filter)
                    _buildProfileOption(Icons.reorder, 'Orders', () async {
                      try {
                        // Fetching orders from Firestore without filtering by email
                        QuerySnapshot orderSnapshot = await _firestore
                            .collection('orders')
                            .orderBy('orderDate',
                                descending:
                                    true) // Order by the date the order was placed
                            .get();

                        if (orderSnapshot.docs.isNotEmpty) {
                          // Show a list of orders
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Your Orders'),
                              content: SizedBox(
                                width: double.maxFinite,
                                height: 300,
                                child: ListView(
                                  children: orderSnapshot.docs.map((orderDoc) {
                                    var order =
                                        orderDoc.data() as Map<String, dynamic>;
                                    List items = order['items'] ??
                                        []; // Safely access the items array
                                    return ListTile(
                                      title: Text(
                                          'Order Number: ${order['orderNumber']}'),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Status: ${order['status']}'),
                                          Text(
                                              'Payment Method: ${order['paymentMethod']}'),
                                          const SizedBox(height: 8),
                                          // Displaying the items in the order
                                          ...items.map((item) {
                                            return Text(
                                              '${item['name']} x${item['quantity']} - ₹${item['price']}',
                                            );
                                          }).toList(),
                                          const SizedBox(height: 8),
                                          Text(
                                              'Total: ₹${order['totalAmount']}'),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        } else {
                          // No orders found
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No orders found!')),
                          );
                        }
                      } catch (e) {
                        // Error fetching orders
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }),

                    _buildProfileOption(Icons.comment, 'Reviews', () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Write a Review'),
                            content: TextField(
                              controller: _reviewController,
                              decoration: const InputDecoration(
                                hintText: 'Enter your review here',
                              ),
                              maxLines: 3,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  _submitReview();
                                  Navigator.pop(context);
                                },
                                child: const Text('Submit'),
                              ),
                            ],
                          );
                        },
                      );
                    }),
                    _buildProfileOption(Icons.location_on, 'Address', () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Address'),
                          content: const Text(
                            'Kottukulam Hills, Pathamuttam P. O, Kerala 686532',
                            style: TextStyle(fontSize: 16),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    }),
                    _buildProfileOption(Icons.lock, 'Change Password',
                        () async {
                      final user = _auth.currentUser;
                      if (user != null) {
                        try {
                          setState(() {
                            _isLoading = true;
                          });
                          await _auth.sendPasswordResetEmail(
                              email: user.email!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Password reset email sent!')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('No user is signed in!')),
                        );
                      }
                    }),
                    _buildProfileOption(Icons.info, 'About Us', () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('About Us'),
                            content: const Text(
                                'Welcome to Gits Bites, your ultimate food ordering companion! We’re here to bring you a seamless, delightful, and personalized food experience by offering a wide variety of cuisines from your favorite restaurants. Whether you re craving a quick snack or a hearty meal, our easy-to-use platform allows you to browse menus, place orders, and track deliveries in just a few taps. With secure payment options, personalized recommendations, and real-time order updates, Gits Bites ensures convenience and quality with every bite, let us satisfy your cravings with just a few taps, wherever you are'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    }),
                    _buildProfileOption(Icons.contact_mail, 'Contact Us', () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Contact Us'),
                            content: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Phone: +91 0481 243 6170'),
                                SizedBox(height: 10),
                                Text('Email: gitsbites@gmail.com'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    }),
                    _buildProfileOption(Icons.language, 'Languages', () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Select a Language'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text('English'),
                                Text('Spanish'),
                                Text('French'),
                                Text('German'),
                                Text('Chinese'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    }),

                    const SizedBox(height: 30),

                    // Edit Button with glowing effect
                    _buildGlowButton(
                      onPressed: () {
                        setState(() {
                          if (_isEditing) {
                            _saveProfile();
                          }
                          _isEditing = !_isEditing; // Toggle editing mode
                        });
                      },
                      text: _isEditing ? 'Save Changes' : 'Edit Profile',
                    ),

                    const SizedBox(height: 20),

                    // Logout Button with glowing effect
                    _buildGlowButton(
                      onPressed: () async {
                        await _auth.signOut();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      text: 'Logout',
                      backgroundColor: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/favorites');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/cart');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }

  // Helper method for profile options
  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: Icon(icon, color: Colors.green),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  // Glowing button widget
  Widget _buildGlowButton({
    required VoidCallback onPressed,
    required String text,
    Color backgroundColor = Colors.green,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 10,
        shadowColor: Colors.green.withOpacity(0.5),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 15,
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}