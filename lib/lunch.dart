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
      "name": "Biriyani",
      "price": 110,
      "image": "assets/biriyani.png",
      "isFavorite": false,
      "inCart": false,
      "quantity": 1,
    },
    {
      "name": "Meals",
      "price": 100,
      "image": "assets/meals.png",
      "isFavorite": false,
      "inCart": false,
      "quantity": 1,
    },
    {
      "name": "Fish Fry",
      "price": 30,
      "image": "assets/fishfry.png",
      "isFavorite": false,
      "inCart": false,
      "quantity": 1,
    },
    {
      "name": "Chicken Curry",
      "price": 60,
      "image": "assets/chickencurry.png",
      "isFavorite": false,
      "inCart": false,
      "quantity": 1,
    },
    {
      "name": " Porotta",
      "price": 12,
      "image": "assets/porotta.png",
      "isFavorite": false,
      "inCart": false,
      "quantity": 1,
    },
    {
      "name": " Chapati",
      "price": 10,
      "image": "assets/chapati.png",
      "isFavorite": false,
      "inCart": false,
      "quantity": 1,
    },
    {
      "name": "Egg Curry",
      "price": 40,
      "image": "assets/eggcurry.png",
      "isFavorite": false,
      "inCart": false,
      "quantity": 1,
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
      } else {
        // Add to cart if not in list
        item['inCart'] = true;
        cartItems.add(item);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(item['inCart']
            ? "${item['name']} added to cart!"
            : "${item['name']} removed from cart!"),
        duration: const Duration(seconds: 2),
      ),
    );
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
                              toggleFavorite(
                                  index); // Toggle favorite on button press
                            },
                          ),
                          // Cart Button
                          IconButton(
                            icon: Icon(
                              item['inCart']
                                  ? Icons.shopping_cart
                                  : Icons.add_shopping_cart,
                              color:
                                  item['inCart'] ? Colors.green : Colors.grey,
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
        currentIndex: 1,
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
