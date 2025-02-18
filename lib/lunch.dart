import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bottom_nav.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LunchPage extends StatefulWidget {
  const LunchPage({super.key});

  @override
  _LunchPageState createState() => _LunchPageState();
}

class _LunchPageState extends State<LunchPage> {
  final List<Map<String, dynamic>> favoriteItems = [];
  final List<Map<String, dynamic>> cartItems = [];
  double totalPrice = 0.0;

  User? currentUser = FirebaseAuth.instance.currentUser;
  void toggleFavorite(Map<String, dynamic> item) async {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in!')),
      );
      return;
    }

    final userFavoritesRef = FirebaseFirestore.instance
        .collection('trial database')
        .doc(currentUser!.uid)
        .collection('favourites');

    final querySnapshot = await userFavoritesRef
        .where('Item_Name', isEqualTo: item['Item_Name'])
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      await querySnapshot.docs.first.reference.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${item['Item_Name']} removed from favorites!")),
      );
    } else {
      await userFavoritesRef.add(item);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${item['Item_Name']} added to favorites!")),
      );
    }
    setState(() {});
  }

  void addToCart(Map<String, dynamic> item) async {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in!')),
      );
      return;
    }

    final userCartRef = FirebaseFirestore.instance
        .collection('trial database')
        .doc(currentUser!.uid)
        .collection('cart');

    try {
      // Check if the item already exists in the cart
      final querySnapshot = await userCartRef
          .where('Item_Name', isEqualTo: item['Item_Name'])
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // If item exists, update the quantity
        final doc = querySnapshot.docs.first;
        final currentQuantity = doc['quantity'] ?? 1;
        await doc.reference.update({'quantity': currentQuantity + 1});
      } else {
        // If item does not exist, add a new entry
        await userCartRef.add({
          'Item_Name': item['Item_Name'],
          'Price': item['Price'],
          'quantity': 1,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // Update the total price in Firestore
      totalPrice += item['Price'];
      final userDocRef = FirebaseFirestore.instance
          .collection('trial database')
          .doc(currentUser!.uid);
      await userDocRef
          .set({'Total_Price': totalPrice}, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${item['Item_Name']} added to cart!"),
          duration: const Duration(seconds: 1),
        ),
      );

      setState(() {}); // Refresh UI to reflect changes
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding item to cart: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lunch Menu', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Stream for menu items
        stream: FirebaseFirestore.instance
            .collection('Menu_Lunch')
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
            return const Center(child: Text('No lunch items available.'));
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
                            : const Icon(Icons.fastfood,
                                size: 60, color: Colors.grey),
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Cart Button with dynamic color change
                          IconButton(
                            icon: Icon(
                              cartItems.contains(itemData)
                                  ? Icons.shopping_cart
                                  : Icons.add_shopping_cart,
                              color: cartItems.contains(itemData)
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            onPressed: () => addToCart(itemData),
                          ),
                          // Favorite Button
                          IconButton(
                            icon: Icon(
                              favoriteItems.contains(itemData)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: favoriteItems.contains(itemData)
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                            onPressed: () => toggleFavorite(itemData),
                          ),
                        ],
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
