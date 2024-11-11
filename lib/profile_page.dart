import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile picture and name
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(
                        'assets/profile_pic.png'), // Replace with actual image path
                    backgroundColor: Colors.grey[200],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Alhaarith Hakkim',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Personal Details section
            Text(
              'Personal Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Personal details cards
            Card(
              child: ListTile(
                leading: Icon(Icons.school),
                title: Text('Computer Science'),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text('21-25'),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.email),
                title: Text('ahh.csa2125@saintgits.org'),
              ),
            ),
            SizedBox(height: 20),

            // Recent Orders section
            Text(
              'Recent Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Recent order card
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(
                      'assets/profile_pic.png'), // Replace with actual image path
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
                        Icon(Icons.star_half, color: Colors.amber, size: 18),
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
    );
  }
}
