import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'bottom_nav.dart';

class LunchPage extends StatefulWidget {
  const LunchPage({super.key});

  @override
  _LunchPageState createState() => _LunchPageState();
}

class _LunchPageState extends State<LunchPage> {
  final List<Map<String, dynamic>> favoriteItems = [];
  final List<Map<String, dynamic>> cartItems = [];
  User? currentUser = FirebaseAuth.instance.currentUser;

  void toggleFavorite(Map<String, dynamic> itemData) async {
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
        .where('Item_Name', isEqualTo: itemData['Item_Name'])
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      await querySnapshot.docs.first.reference.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("${itemData['Item_Name']} removed from favorites!")),
      );
    } else {
      await userFavoritesRef.add(itemData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${itemData['Item_Name']} added to favorites!")),
      );
    }
    setState(() {});
  }

  void addToCart(Map<String, dynamic> itemData) async {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in!')),
      );
      return;
    }

    try {
      final userCartRef = FirebaseFirestore.instance
          .collection('trial database')
          .doc(currentUser!.uid)
          .collection('cart');

      final querySnapshot = await userCartRef
          .where('Item_Name', isEqualTo: itemData['Item_Name'])
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final currentQuantity = doc['quantity'] ?? 1;
        await doc.reference.update({'quantity': currentQuantity + 1});
      } else {
        await userCartRef.add({
          'Item_Name': itemData['Item_Name'],
          'Price': itemData['Price'],
          'quantity': 1,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${itemData['Item_Name']} added to cart!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding to cart: $e')),
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
        stream: FirebaseFirestore.instance
            .collection('Menu_Lunch')
            .where('Stock', isGreaterThan: 0) // Only show items with stock > 0
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

          return Stack(
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
                itemCount: snapshot.data!.docs.length,
                padding: const EdgeInsets.only(bottom: 80),
                itemBuilder: (context, index) {
                  final itemData =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                                Text(
                                  "Stock: ${itemData['Stock']}",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add_shopping_cart),
                                color: Colors.grey,
                                onPressed: () => addToCart(itemData),
                              ),
                              IconButton(
                                icon: const Icon(Icons.favorite_border),
                                color: Colors.grey,
                                onPressed: () => toggleFavorite(itemData),
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
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
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
