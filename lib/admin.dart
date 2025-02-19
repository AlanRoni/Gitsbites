import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        elevation: 4.0,
        shadowColor: Colors.grey.shade300,
        iconTheme:
            const IconThemeData(color: Colors.white), // White back button
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.green.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Menu Button
              SizedBox(
                width: MediaQuery.of(context).size.width *
                    0.8, // 80% of screen width
                height: 100, // Increased height
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 8, // Add shadow
                    padding: const EdgeInsets.all(16), // Add padding
                  ),
                  onPressed: () {
                    // Navigate to the Admin Menu Page
                    Navigator.pushNamed(context, '/admin_menu');
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.menu_book,
                          color: Colors.white, size: 30), // Add icon
                      SizedBox(width: 10), // Space between icon and text
                      Text(
                        'Menu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24, // Increased font size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30), // Increased spacing between buttons
              // Pending Orders Button
              SizedBox(
                width: MediaQuery.of(context).size.width *
                    0.8, // 80% of screen width
                height: 100, // Increased height
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 8, // Add shadow
                    padding: const EdgeInsets.all(16), // Add padding
                  ),
                  onPressed: () {
                    // Navigate to the Pending Orders Page
                    Navigator.pushNamed(context, '/admin_pending_orders');
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.list_alt,
                          color: Colors.white, size: 30), // Add icon
                      SizedBox(width: 10), // Space between icon and text
                      Text(
                        'Pending Orders',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24, // Increased font size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}