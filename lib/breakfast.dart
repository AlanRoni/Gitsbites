import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gitsbites/bottom_nav.dart';

class BreakfastPage extends StatefulWidget {
  const BreakfastPage({super.key});

  @override
  _BreakfastPageState createState() => _BreakfastPageState();
}

class _BreakfastPageState extends State<BreakfastPage> {
  final List<Map<String, dynamic>> cartItems = [];
  double totalPrice = 0.0;
  User? currentUser = FirebaseAuth.instance.currentUser;

  // Function to toggle favorite status and update Firestore
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
      final querySnapshot = await userCartRef
          .where('Item_Name', isEqualTo: item['Item_Name'])
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final currentQuantity = doc['quantity'] ?? 1;
        await doc.reference.update({'quantity': currentQuantity + 1});
      } else {
        await userCartRef.add({
          'Item_Name': item['Item_Name'],
          'Price': item['Price'],
          'quantity': 1,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      totalPrice += item['Price'];
      final userDocRef = FirebaseFirestore.instance
          .collection('trial database')
          .doc(currentUser!.uid);
      await userDocRef
          .set({'Total_Price': totalPrice}, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${item['Item_Name']} added to cart!")),
      );

      setState(() {});
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
        title:
            const Text('Breakfast Menu', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Menu_Breakfast')
            .where('Stock', isGreaterThan: 0)
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
                            ? Image.network(itemData["imageURL"],
                                width: 60, height: 60, fit: BoxFit.cover)
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
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "INR ${itemData['Price'] ?? 'N/A'}",
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add_shopping_cart,
                                color: Colors.grey),
                            onPressed: () => addToCart(itemData),
                          ),
                          IconButton(
                            icon: const Icon(Icons.favorite_border,
                                color: Colors.grey),
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
          final routes = ['/home', '/favorites', '/cart', '/profile'];
          Navigator.pushReplacementNamed(context, routes[index]);
        },
      ),
    );
  }
}