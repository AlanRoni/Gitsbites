import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'bottom_nav.dart';

class BreakfastPage extends StatefulWidget {
  const BreakfastPage({super.key});

  @override
  _BreakfastPageState createState() => _BreakfastPageState();
}

class _BreakfastPageState extends State<BreakfastPage> {
  final List<Map<String, dynamic>> menuItems = [
    {
      "name": "Puttu ",
      "price": 40,
      "image": "assets/puttu.png",
      "isFavorite": false,
      "inCart": false,
      "quantity": 1,
    },
    {
      "name": "Idli and Sambar(Nos:4)",
      "price": 55,
      "image": "assets/idli.png",
      "isFavorite": false,
      "inCart": false,
      "quantity": 1,
    },
    {
      "name": "Chapati",
      "price": 10,
      "image": "assets/chapati.png",
      "isFavorite": false,
      "inCart": false,
      "quantity": 1,
    },
    {
      "name": "Appam",
      "price": 12,
      "image": "assets/appam.png",
      "isFavorite": false,
      "inCart": false,
      "quantity": 1,
    },
    {
      "name": "Porotta",
      "price": 12,
      "image": "assets/porotta.png",
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
      "name": "Kadala Curry",
      "price": 20,
      "image": "assets/kadalacurry.png",
      "isFavorite": false,
      "inCart": false,
      "quantity": 1,
    },
    {
      "name": "Egg Curry",
      "price": 40,
      "image": "eggcurry.png",
      "isFavorite": false,
      "inCart": false,
      "quantity": 1,
    },
  ];

  final List<Map<String, dynamic>> favoriteItems = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
  Future<void> toggleCart(int index) async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to add items to cart")),
      );
      return;
    }

    final item = menuItems[index];
    final cartRef = _firestore
        .collection('trial database')
        .doc(user.uid)
        .collection('cart')
        .doc(item['name']);

    try {
      if (item['inCart']) {
        // Remove from cart
        await cartRef.delete();
        setState(() {
          item['inCart'] = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${item['name']} removed from cart!")),
        );
      } else {
        // Add to cart
        await cartRef.set({
          'Item_Name': item['name'],
          'Price': item['price'],
          'image': item['image'],
          'quantity': item['quantity'],
          'createdAt': FieldValue.serverTimestamp(),
        });
        setState(() {
          item['inCart'] = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${item['name']} added to cart!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Breakfast Menu', style: TextStyle(color: Colors.white)),
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
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(
              context,
              '/favorites',
              arguments: favoriteItems,
            );
          } else if (index == 2) {
            // Modified this part - no need to pass cartItems since CartPage will fetch from Firestore
            Navigator.pushReplacementNamed(context, '/cart');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }
}
