import 'package:flutter/material.dart';
import 'bottom_nav.dart';
import 'cart_page.dart'; // Import CartPage

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Map<String, dynamic>> favoriteItems = [];
  final List<Map<String, dynamic>> _cartItems = []; // Cart items list

  void removeItem(int index) {
    setState(() {
      favoriteItems.removeAt(index); // Remove item from favorites
    });
  }

  void addToCart(Map<String, dynamic> item) {
    setState(() {
      // Check if item is already in cart, update quantity if needed
      int existingIndex =
          _cartItems.indexWhere((cartItem) => cartItem['name'] == item['name']);
      if (existingIndex != -1) {
        _cartItems[existingIndex]['quantity'] += 1; // Increase quantity
      } else {
        _cartItems.add({...item, 'quantity': 1}); // Add new item with quantity
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${item['name']} added to cart"),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>>? newFavorites = ModalRoute.of(context)
        ?.settings
        .arguments as List<Map<String, dynamic>>?;

    if (newFavorites != null) {
      favoriteItems = newFavorites;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CartPage(),
                  settings:
                      RouteSettings(arguments: _cartItems), // Pass cart items
                ),
              );
            },
          ),
        ],
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
          favoriteItems.isEmpty
              ? const Center(
                  child: Text(
                    "No favorite items yet!",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: favoriteItems.length,
                  itemBuilder: (context, index) {
                    final item = favoriteItems[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            item["image"],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(item["name"]),
                        subtitle: Text("INR ${item['price']}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.favorite,
                                  color: Colors.green),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text("Remove Item"),
                                      content: Text(
                                          "Remove '${item['name']}' from favorites?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text("No"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            removeItem(index);
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text("Yes"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.shopping_cart,
                                  color: Colors.blue),
                              onPressed: () {
                                addToCart(item); // Add item to cart
                              },
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
          if (index == 0) Navigator.pushReplacementNamed(context, '/home');
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/favorites',
                arguments: favoriteItems);
          }
          if (index == 2) {
            Navigator.pushReplacementNamed(context, '/cart',
                arguments: _cartItems);
          }
          if (index == 3) Navigator.pushReplacementNamed(context, '/profile');
        },
      ),
    );
  }
}
