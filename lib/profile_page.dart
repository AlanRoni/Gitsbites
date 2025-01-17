import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFE8F5E9)
            ], // Subtle gradient background
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Banner with Profile Picture and Name
              Stack(
                children: [
                  Container(
                    height: 220,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF00796B),
                          Color(0xFF004D40)
                        ], // Green gradient
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 16,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 60),
                      Center(
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: const AssetImage(
                              'assets/profile_pic.png'), // Profile picture
                          backgroundColor: Colors.grey[300],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Center(
                        child: Text(
                          'Alhaarith Hakkim',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Center(
                        child: Text(
                          'ahh.csa2125@saintgits.org',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Personal Details Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF004D40),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildInfoCard(
                      icon: Icons.school,
                      title: 'Computer Science',
                    ),
                    _buildInfoCard(
                      icon: Icons.calendar_today,
                      title: '21-25',
                    ),
                    _buildInfoCard(
                      icon: Icons.email,
                      title: 'ahh.csa2125@saintgits.org',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Recent Orders Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Orders',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF004D40),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildRecentOrderCard(
                      name: 'Alhaarith Hakkim',
                      timeAgo: '2 days ago',
                      rating: 4.5,
                      foodItem: 'Rice and Curry',
                      avatarPath: 'assets/profile_pic.png',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to build personal details cards
  Widget _buildInfoCard({required IconData icon, required String title}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF00796B)),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
    );
  }

  // Helper to build recent orders cards
  Widget _buildRecentOrderCard({
    required String name,
    required String timeAgo,
    required double rating,
    required String foodItem,
    required String avatarPath,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage:
                  AssetImage(avatarPath), // Replace with actual path
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    timeAgo,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: List.generate(
                        5,
                        (index) => Icon(
                              index < rating.floor()
                                  ? Icons.star
                                  : Icons.star_half,
                              color: Colors.amber,
                              size: 18,
                            )),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    foodItem,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
