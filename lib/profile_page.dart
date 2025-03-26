import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _nameController.text = user.displayName ?? '';
        _emailController.text = user.email ?? '';
      });

      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc['profilePicUrl'] != null) {
          setState(() {
            _profilePicFile = null;
          });
        }
      } catch (e) {
        debugPrint('Error fetching user data: $e');
      }
    }
  }

  Future<void> _saveProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      String? profilePicUrl;
      if (_profilePicFile != null) {
        final storageRef = _storage.ref().child('profile_pics/${user.uid}.jpg');
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

      _showSuccessSnackBar('Profile updated successfully!');
    } catch (e) {
      _showErrorSnackBar('Error updating profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _profilePicFile = File(pickedFile.path));
    }
  }

  Future<void> _submitReview() async {
    final user = _auth.currentUser;
    if (user == null || _reviewController.text.isEmpty) return;

    try {
      await _firestore.collection('reviews').add({
        'userId': user.uid,
        'name': user.displayName ?? 'Anonymous',
        'email': user.email ?? 'No email',
        'review': _reviewController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _showSuccessSnackBar('Review submitted successfully!');
      _reviewController.clear();
    } catch (e) {
      _showErrorSnackBar('Error submitting review: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[800],
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
            color: Colors.white,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Header Section
              _buildProfileHeader(),
              const SizedBox(height: 30),

              // Account Section
              _buildSectionHeader('Account'),
              _buildProfileOption(
                icon: Icons.receipt_long_outlined,
                title: 'My Orders',
                onTap: _showOrderHistory,
              ),
              _buildProfileOption(
                icon: Icons.favorite_border,
                title: 'Favorites',
                onTap: () {},
              ),
              _buildProfileOption(
                icon: Icons.location_on_outlined,
                title: 'Saved Addresses',
                onTap: _showAddressDialog,
              ),
              _buildProfileOption(
                icon: Icons.payment_outlined,
                title: 'Payment Methods',
                onTap: () {},
              ),

              // App Section
              _buildSectionHeader('App'),
              _buildProfileOption(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () {},
              ),
              _buildProfileOption(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: _showHelpDialog,
              ),
              _buildProfileOption(
                icon: Icons.info_outline,
                title: 'About Us',
                onTap: _showAboutDialog,
              ),
              _buildProfileOption(
                icon: Icons.star_outline,
                title: 'Rate Us',
                onTap: () {},
              ),

              // Action Buttons
              const SizedBox(height: 30),
              _buildActionButton(
                text: _isEditing ? 'SAVE CHANGES' : 'EDIT PROFILE',
                onPressed: _toggleEditMode,
                icon: Icons.edit_outlined,
              ),
              const SizedBox(height: 15),
              _buildActionButton(
                text: 'LOGOUT',
                onPressed: _logout,
                icon: Icons.logout,
                backgroundColor: Colors.red[400],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/home');
          if (index == 1) Navigator.pushReplacementNamed(context, '/favorites');
          if (index == 2) Navigator.pushReplacementNamed(context, '/cart');
          if (index == 3) Navigator.pushReplacementNamed(context, '/profile');
        },
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.green[800]!,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: _profilePicFile != null
                    ? FileImage(_profilePicFile!)
                    : const AssetImage('assets/default_profile.png')
                        as ImageProvider,
                child: _isEditing
                    ? Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 30,
                        ),
                      )
                    : null,
              ),
            ),
            if (_isEditing)
              FloatingActionButton.small(
                onPressed: _pickProfilePicture,
                backgroundColor: Colors.green[800],
                child: const Icon(Icons.edit, color: Colors.white),
              ),
          ],
        ),
        const SizedBox(height: 15),
        _isEditing
            ? TextField(
                controller: _nameController,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              )
            : Text(
                _nameController.text.isEmpty
                    ? 'Your Name'
                    : _nameController.text,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
        const SizedBox(height: 5),
        Text(
          _emailController.text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const Expanded(
            child: Divider(
              indent: 10,
              endIndent: 10,
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.green[800], size: 22),
              ),
              const SizedBox(width: 15),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
    required IconData icon,
    Color? backgroundColor,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.green[800],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  void _toggleEditMode() {
    setState(() {
      if (_isEditing) {
        _saveProfile();
      }
      _isEditing = !_isEditing;
    });
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _showOrderHistory() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      QuerySnapshot orderSnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .orderBy('orderDate', descending: true)
          .get();

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Order History',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                if (orderSnapshot.docs.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text('No orders found'),
                  )
                else
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    width: double.maxFinite,
                    child: ListView.separated(
                      itemCount: orderSnapshot.docs.length,
                      separatorBuilder: (_, __) => const Divider(height: 20),
                      itemBuilder: (context, index) {
                        var order = orderSnapshot.docs[index].data()
                            as Map<String, dynamic>;
                        return OrderItemCard(order: order);
                      },
                    ),
                  ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CLOSE'),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Error fetching orders: $e');
    }
  }

  void _showAddressDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Saved Address'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kottukulam Hills, Pathamuttam P. O',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 5),
            Text('Kerala 686532', style: TextStyle(fontSize: 16)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phone: +91 0481 243 6170'),
            SizedBox(height: 10),
            Text('Email: gitsbites@gmail.com'),
            SizedBox(height: 15),
            Text(
              'We\'re available 24/7 to assist you with any questions or issues.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About GitsBites'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome to Gits Bites, your ultimate food ordering companion!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'We\'re here to bring you a seamless, delightful, and personalized food experience by offering a wide variety of cuisines from your favorite restaurants. Whether you\'re craving a quick snack or a hearty meal, our easy-to-use platform allows you to browse menus, place orders, and track deliveries in just a few taps.',
              ),
              const SizedBox(height: 10),
              const Text(
                'With secure payment options, personalized recommendations, and real-time order updates, Gits Bites ensures convenience and quality with every bite.',
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.facebook, size: 30),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 15),
                  IconButton(
                    icon: const Icon(Icons.camera_alt, size: 30),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 15),
                  IconButton(
                    icon: const Icon(Icons.link, size: 30),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }
}

class OrderItemCard extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderItemCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order['orderNumber']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Chip(
                  label: Text(
                    order['status']?.toString().toUpperCase() ?? 'PENDING',
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: _getStatusColor(order['status']),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${order['items']?.length ?? 0} items • ${_formatDate(order['orderDate'])}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            ...(order['items'] as List<dynamic>?)?.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${item['name']} x${item['quantity']}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            '₹${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    )) ??
                [],
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '₹${order['totalAmount']?.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green[100]!;
      case 'cancelled':
        return Colors.red[100]!;
      case 'processing':
        return Colors.blue[100]!;
      default:
        return Colors.orange[100]!;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown date';
    DateTime orderDate = date is Timestamp ? date.toDate() : DateTime.now();
    return '${orderDate.day}/${orderDate.month}/${orderDate.year}';
  }
}
