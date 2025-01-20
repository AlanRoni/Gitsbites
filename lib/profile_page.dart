import 'package:flutter/material.dart';
import 'bottom_nav.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'Profile',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.person_outline,
              size: 24,
              color: Colors.white,
            ),
          ],
        ),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Stack(
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture and Name
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: const AssetImage(
                          'assets/profile_pic.png', // Replace with actual image path
                        ),
                        backgroundColor: Colors.grey[200],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Alhaarith Hakkim',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Personal Details Section
                const Text(
                  'Personal Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                // Personal Details Cards
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.school),
                    title: Text('Computer Science'),
                  ),
                ),
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.calendar_today),
                    title: Text('21-25'),
                  ),
                ),
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.email),
                    title: Text('ahh.csa2125@saintgits.org'),
                  ),
                ),
                const SizedBox(height: 20),

                // Recent Orders Section
                const Text(
                  'Recent Orders',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                // Recent Order Card
                const Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(
                        'assets/profile_pic.png', // Replace with actual image path
                      ),
                    ),
                    title: Text('Alhaarith Hakkim'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('2 days ago'),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 18),
                            Icon(Icons.star, color: Colors.amber, size: 18),
                            Icon(Icons.star, color: Colors.amber, size: 18),
                            Icon(Icons.star, color: Colors.amber, size: 18),
                            Icon(Icons.star_half,
                                color: Colors.amber, size: 18),
                            SizedBox(width: 10),
                            Text('4.5'),
                          ],
                        ),
                        SizedBox(height: 5),
                        Text('Rice and Curry'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
}
