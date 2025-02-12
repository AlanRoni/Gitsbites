import 'package:flutter/material.dart';
import 'bottom_nav.dart';
import 'favorites_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';

class BreakfastPage extends StatefulWidget {
  const BreakfastPage({super.key});

  @override
  _BreakfastPageState createState() => _BreakfastPageState();
}

class _BreakfastPageState extends State<BreakfastPage> {
  final List<Map<String, dynamic>> menuItems = [
    {
      "name": "Puttu",
      "price": 50,
      "image": "assets/item4.png",
      "isFavorite": false,
      "inCart": false,
    },
    {
      "name": "Idli",
      "price": 40,
      "image": "assets/item5.png",
      "isFavorite": false,
      "inCart": false,
    },
    {
      "name": "Chapati and Kadala Curry",
      "price": 100,
      "image": "assets/item1.png",
      "isFavorite": false,
      "inCart": false,
    },
    {
      "name": "Appam and Egg Curry",
      "price": 90,
      "image": "assets/item2.png",
      "isFavorite": false,
      "inCart": false,
    },
    {
      "name": "Dosa and Chutney",
      "price": 60,
      "image": "assets/item3.png",
      "isFavorite": false,
      "inCart": false,
    },
  ];

  final List<Map<String, dynamic>> favoriteItems = [];
  final List<Map<String, dynamic>> cartItems = [];

  // Toggle favorite status for each item
  void toggleFavorite(int index) {
    final item = menuItems[index];

    setState(() {
      if (item['isFavorite']) {
        // Remove from favorites if already in list
        item['isFavorite'] = false;
        favoriteItems.removeWhere((fav) => fav['name'] == item['name']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${item['name']} removed from favorites!"),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // Add to favorites if not in list
        item['isFavorite'] = true;
        favoriteItems.add(item);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${item['name']} added to favorites!"),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  // Toggle cart status for each item
  void toggleCart(int index) {
    final item = menuItems[index];

    setState(() {
      if (item['inCart']) {
        // Remove from cart if already in list
        item['inCart'] = false;
        cartItems.removeWhere((cartItem) => cartItem['name'] == item['name']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${item['name']} removed from cart!"),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // Add to cart if not in list
        item['inCart'] = true;
        cartItems.add(item);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${item['name']} added to cart!"),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breakfast Menu', style: TextStyle(color: Colors.white)),
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
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          item["image"],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item["name"],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "INR ${item['price']}",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Favorite Button
                          IconButton(
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
                          // Cart Button
                          IconButton(
                            icon: Icon(
                              item['inCart']
                                  ? Icons.shopping_cart
                                  : Icons.add_shopping_cart,
                              color: item['inCart'] ? Colors.green : Colors.grey,
                            ),
                            onPressed: () {
                              toggleCart(index); // Toggle cart on button press
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(
              context,
              '/favorites',
              arguments: favoriteItems, // Pass favoriteItems to FavoritesPage
            );
          } else if (index == 2) {
            Navigator.pushReplacementNamed(
              context,
              '/cart',
              arguments: cartItems, // Pass cartItems to CartPage
            );
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }
}
