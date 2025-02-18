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

                    // Profile options list with glowing buttons
                    _buildProfileOption(Icons.reorder, 'Orders', () {}),
                    _buildProfileOption(Icons.comment, 'Reviews', () {}),
                    _buildProfileOption(Icons.location_on, 'Address', () {}),
                    _buildProfileOption(Icons.lock, 'Change Password', () {}),
                    _buildProfileOption(Icons.info, 'About Us', () {}),
                    _buildProfileOption(
                        Icons.contact_mail, 'Contact Us', () {}),
                    _buildProfileOption(Icons.language, 'Languages', () {}),

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