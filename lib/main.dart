import 'package:flutter/material.dart';
import 'cart_page.dart';
import 'profile_page.dart';
import 'favorites_page.dart';
import 'bottom_nav.dart';
import 'payment.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Kioski App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        initialRoute: '/home',
        routes: {
          '/home': (context) => const HomePage(),
          '/favorites': (context) => const FavoritesPage(),
          '/cart': (context) => const CartPage(),
          '/profile': (context) => const ProfilePage(),
          '/payment': (context) =>
              const PaymentPage(totalAmount: 0, cartItems: []),
        });
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> menuItems = [
    {
      "name": "Lentil Fritters",
      "price": 10,
      "image": "assets/item1.png",
      "isFavorite": false,
      "inCart": false,
    },
    {
      "name": "Chicken Fried Rice",
      "price": 150,
      "image": "assets/item2.png",
      "isFavorite": false,
      "inCart": false,
    },
    {
      "name": "Stringhoppers",
      "price": 10,
      "image": "assets/item3.png",
      "isFavorite": false,
      "inCart": false,
    },
    {
      "name": "Chocolate Milkshake",
      "price": 90,
      "image": "assets/item1.png",
      "isFavorite": false,
      "inCart": false,
    },
  ];

  final List<Map<String, dynamic>> favoriteItems = [];
  final List<Map<String, dynamic>> cartItems = [];

  void toggleFavorite(int index) {
    final item = menuItems[index];

    // Check if item is already in the favorites
    final existingIndex =
        favoriteItems.indexWhere((fav) => fav['name'] == item['name']);
    if (existingIndex != -1) {
      // Show popup if item is already in the favorites
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("The item is already in the favorites!"),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // Add to favorites and update the heart icon
      setState(() {
        item['isFavorite'] = true;
        favoriteItems.add(item);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${item['name']} added to favorites!"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void toggleCart(int index) {
    final item = menuItems[index];

    // Check if the item is already in the cart
    final existingIndex = cartItems.indexWhere((cartItem) => cartItem['name'] == item['name']);
    if (existingIndex != -1) {
      // Show popup if item is already in the cart
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("The item is already in the cart!"),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // Add to cart and update the cart icon
      setState(() {
        item['inCart'] = true;
        cartItems.add({...item, "quantity": 1}); // Add a "quantity" field
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${item['name']} added to cart!"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Color(0xFFA8D5A3)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Menu Items
          ListView.builder(
            itemCount: menuItems.length,
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
                        children: [
                          IconButton(
                            icon: Icon(
                              item['inCart'] ? Icons.shopping_cart : Icons.add_shopping_cart,
                              color: item['inCart'] ? Colors.green : Colors.grey,
                            ),
                            onPressed: () {
                              toggleCart(index);
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              item['isFavorite']
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color:
                                  item['isFavorite'] ? Colors.red : Colors.grey,
                            ),
                            onPressed: () {
                              toggleFavorite(index);
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
            Navigator.pushReplacementNamed(context, '/favorites',
                arguments: favoriteItems);
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/cart',
                arguments: cartItems);
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }
}
