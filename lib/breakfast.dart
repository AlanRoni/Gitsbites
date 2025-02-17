import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'bottom_nav.dart';
=======
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gitsbites/bottom_nav.dart';
>>>>>>> e3002f71b3c7dabb11c1211d56780e178908e490

class BreakfastPage extends StatefulWidget {
  const BreakfastPage({super.key});

  @override
  _BreakfastPageState createState() => _BreakfastPageState();
}

class _BreakfastPageState extends State<BreakfastPage> {
  final List<Map<String, dynamic>> favoriteItems = [];
  final List<Map<String, dynamic>> cartItems = [];

  void toggleFavorite(Map<String, dynamic> item) {
    setState(() {
      if (favoriteItems.contains(item)) {
        favoriteItems.remove(item);
      } else {
        favoriteItems.add(item);
      }
    });
  }

  void addToCart(Map<String, dynamic> item) {
    setState(() {
      cartItems.add(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${item['Item_Name']} added to cart!"),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breakfast Menu', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Menu_Breakfast')
            .where('Stock', isGreaterThan: 0) // Show only items with stock > 0
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No breakfast items available.'));
          }

          final menuItems = snapshot.data!.docs;

          return ListView.builder(
            itemCount: menuItems.length,
            padding: const EdgeInsets.only(bottom: 80),
            itemBuilder: (context, index) {
              final item = menuItems[index];
              final itemData = item.data() as Map<String, dynamic>;

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
                        child: itemData.containsKey("imageURL")
                            ? Image.network(
                                itemData["imageURL"],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.fastfood, size: 60, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              itemData["Item_Name"] ?? "Unknown Item",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "INR ${itemData['Price'] ?? 'N/A'}",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.shopping_cart),
                        color: Colors.green,
                        onPressed: () => addToCart(itemData),
                      ),
                      IconButton(
                        icon: Icon(
                          favoriteItems.contains(itemData) ? Icons.favorite : Icons.favorite_border,
                          color: favoriteItems.contains(itemData) ? Colors.red : Colors.grey,
                        ),
                        onPressed: () => toggleFavorite(itemData),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
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