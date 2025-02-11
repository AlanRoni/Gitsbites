import 'package:flutter/material.dart';
import 'bottom_nav.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Map<String, dynamic>> favoriteItems = [];

  void removeItem(int index) {
    setState(() {
      favoriteItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get favorites passed from HomePage
    final List<Map<String, dynamic>>? newFavorites =
        ModalRoute.of(context)?.settings.arguments as List<Map<String, dynamic>>?;
    if (newFavorites != null) {
      favoriteItems = newFavorites;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
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
          // Favorites List
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
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: () {
                            // Show confirmation dialog
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("Remove Item"),
                                  content: Text(
                                      "Are you sure you want to remove '${item['name']}' from favorites?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Close dialog
                                      },
                                      child: const Text("No"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        removeItem(index);
                                        Navigator.of(context).pop(); // Close dialog
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