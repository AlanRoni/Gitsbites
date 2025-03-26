import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'bottom_nav.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Map<String, dynamic>> favoriteItems = [];

  @override
  void initState() {
    super.initState();
    fetchFavoriteItems(); // Fetch favorite items on initialization
  }

  Future<void> fetchFavoriteItems() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final favouritesRef = FirebaseFirestore.instance
          .collection('trial database')
          .doc(user.uid)
          .collection('favourites');
      final snapshot = await favouritesRef.get();

      List<Map<String, dynamic>> items = [];
      for (var doc in snapshot.docs) {
        var data = doc.data();

        // Ensuring null checks for each field in favorites as well
        String itemName =
            data['Item_Name'] ?? "Unnamed Item"; // fallback if null
        String image = data['image'] ?? ""; // fallback if null
        double price = data['Price']?.toDouble() ?? 0.0; // fallback if null

        items.add({
          'name': itemName,
          'image': image,
          'price': price,
        });
      }

      setState(() {
        favoriteItems = items;
      });
    }
  }

  void removeItem(int index) {
    setState(() {
      favoriteItems.removeAt(index); // Remove item from favorites
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites', style: TextStyle(color: Colors.white)),
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
                        trailing: IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.green),
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
          if (index == 2) Navigator.pushReplacementNamed(context, '/cart');
          if (index == 3) Navigator.pushReplacementNamed(context, '/profile');
        },
      ),
    );
  }
}
