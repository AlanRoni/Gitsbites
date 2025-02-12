import 'package:flutter/material.dart';
import 'bottom_nav.dart';

class LunchPage extends StatefulWidget {
  const LunchPage({super.key});

  @override
  _LunchPageState createState() => _LunchPageState();
}

class _LunchPageState extends State<LunchPage> {
  final List<Map<String, dynamic>> menuItems = [
    {
      "name": "Meals",
      "price": 100,
      "image": "assets/item7.png",
      "isFavorite": false,
      "inCart": false,
    },
    {
      "name": "Biriyani",
      "price": 110,
      "image": "assets/item6.png",
      "isFavorite": false,
      "inCart": false,
    },
    {
      "name": "Chapati and Chicken Curry",
      "price": 110,
      "image": "assets/item8.png",
      "isFavorite": false,
      "inCart": false,
    },
    {
      "name": "Porotta and Chicken Curry",
      "price": 120,
      "image": "assets/item9.png",
      "isFavorite": false,
      "inCart": false,
    },
  ];

  // This will hold the list of favorite items
  List<Map<String, dynamic>> favoriteItems = [];

  // Toggle favorite status for each item
  void toggleFavorite(int index) {
    setState(() {
      final item = menuItems[index];
      item['isFavorite'] = !item['isFavorite']; // Toggle favorite status

      if (item['isFavorite']) {
        favoriteItems.add(item); // Add to favorites
      } else {
        favoriteItems.removeWhere(
            (fav) => fav['name'] == item['name']); // Remove from favorites
      }
    });

    final item = menuItems[index];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(item['isFavorite']
            ? "${item['name']} added to favorites!"
            : "${item['name']} removed from favorites!"),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onNavItemTapped(int index) {
    // Navigate to the respective pages when a button is pressed
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(
          context,
          '/favorites',
          arguments: favoriteItems, // Pass the favorite items list
        );
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/cart');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lunch Menu', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Color(0xFFA8D5A3)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          ListView.builder(
            itemCount: menuItems.length,
            padding: const EdgeInsets.only(bottom: 80),
            itemBuilder: (context, index) {
              final item = menuItems[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
                child: ListTile(
                  leading: Image.asset(item["image"], width: 60, height: 60),
                  title: Text(item["name"]),
                  subtitle: Text("INR ${item['price']}"),
                  trailing: IconButton(
                    icon: Icon(
                      item['isFavorite']
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: item['isFavorite']
                          ? const Color.fromARGB(255, 76, 175, 80)
                          : Colors.grey,
                    ),
                    onPressed: () {
                      toggleFavorite(index); // Toggle favorite on button press
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        onTap: _onNavItemTapped, // This will now handle the navigation logic
      ),
    );
  }
}
