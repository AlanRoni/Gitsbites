import 'package:flutter/material.dart';
import 'cart_page.dart';
import 'profile_page.dart';
import 'favorites_page.dart';
import 'bottom_nav.dart';
import 'payment.dart';

class LunchPage extends StatefulWidget {
  const LunchPage({super.key});

  @override
  _LunchPageState createState() => _LunchPageState();
}

class _LunchPageState extends State<LunchPage> {
  final List<Map<String, dynamic>> menuItems = [
    {
      "name": "Meals",
      "price": 100,
      "image": "assets/item7.png",
      "isFavorite": false,
      "inCart": false,
    },
    {
      "name": "Biriyani",
      "price": 110,
      "image": "assets/item6.png",
      "isFavorite": false,
      "inCart": false,
    },
    
  ];

  final List<Map<String, dynamic>> favoriteItems = [];

  void toggleFavorite(int index) {
    final item = menuItems[index];

    final existingIndex = favoriteItems.indexWhere((fav) => fav['name'] == item['name']);
    if (existingIndex != -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("The item is already in the favorites!"),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
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
                child: ListTile(
                  leading: Image.asset(item["image"], width: 60, height: 60),
                  title: Text(item["name"]),
                  subtitle: Text("INR ${item['price']}"),
                  trailing: IconButton(
                    icon: Icon(item['isFavorite'] ? Icons.favorite : Icons.favorite_border),
                    color: item['isFavorite'] ? Colors.red : Colors.grey,
                    onPressed: () {
                      toggleFavorite(index);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
