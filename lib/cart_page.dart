import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'payment.dart';
import 'bottom_nav.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartItems = [];
  double totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final cartRef = FirebaseFirestore.instance
          .collection('trial database')
          .doc(user.uid)
          .collection('cart');
      final snapshot = await cartRef.get();

      List<Map<String, dynamic>> items = [];
      double total = 0.0;
      for (var doc in snapshot.docs) {
        var data = doc.data();

        // Ensuring null checks for each field
        String itemName =
            data['Item_Name'] ?? "Unnamed Item"; // fallback if null
        String image = data['image'] ?? ""; // fallback if null
        double price = data['Price']?.toDouble() ?? 0.0; // fallback if null
        int quantity = data['quantity']?.toInt() ?? 1; // fallback if null

        items.add(data);
        total += price * quantity;
      }
      setState(() {
        cartItems = items;
        totalPrice = total;
      });
    }
  }

  void increaseQuantity(int index) {
    setState(() {
      cartItems[index]['quantity']++;
    });
    updateCartItem(index);
  }

  void decreaseQuantity(int index) {
    setState(() {
      if (cartItems[index]['quantity'] > 1) {
        cartItems[index]['quantity']--;
      } else {
        cartItems.removeAt(index);
      }
    });
    updateCartItem(index);
  }

  Future<void> updateCartItem(int index) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final cartRef = FirebaseFirestore.instance
          .collection('trial database')
          .doc(user.uid)
          .collection('cart')
          .doc(cartItems[index]['Item_Name']);

      double quantity = cartItems[index]['quantity']?.toDouble() ?? 1.0;
      await cartRef.update({'quantity': quantity});
    }
  }

  Future<void> clearCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final cartRef = FirebaseFirestore.instance
          .collection('trial database')
          .doc(user.uid)
          .collection('cart');

      final batch = FirebaseFirestore.instance.batch();
      final snapshot = await cartRef.get();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      setState(() {
        cartItems.clear();
        totalPrice = 0.0;
      });
    }
  }

  double calculateTotalPrice() {
    double total = 0.0;
    for (var item in cartItems) {
      double price = item['Price']?.toDouble() ?? 0.0; // fallback if null
      int quantity = item['quantity']?.toInt() ?? 1; // fallback if null
      total += price * quantity;
    }
    return total;
  }

  void navigateToPayment() {
    if (cartItems.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentPage(
            totalAmount: calculateTotalPrice().round(),
            cartItems: cartItems
                .map((item) => {
                      'name': item['Item_Name'],
                      'price': item['Price'],
                      'quantity': item['quantity'],
                    })
                .toList(),
            userName: FirebaseAuth.instance.currentUser?.displayName ?? 'Guest',
            userEmail: FirebaseAuth.instance.currentUser?.email ?? 'No Email',
          ),
        ),
      ).then((result) {
        // Refresh cart if payment was successful
        if (result == true) {
          setState(() {
            cartItems.clear();
            totalPrice = 0.0;
          });
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: clearCart,
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
          Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    if (cartItems.isEmpty)
                      const Center(
                        child: Text(
                          "Your cart is empty!",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ),
                    ...cartItems.map((item) {
                      String itemName = item['Item_Name'] ?? "Unnamed Item";
                      String image = item['image'] ?? "";
                      double price = item['Price']?.toDouble() ?? 0.0;
                      int quantity = item['quantity']?.toInt() ?? 1;
                      return ListTile(
                        leading: image.isNotEmpty
                            ? Image.network(image, width: 60, height: 60)
                            : const Icon(Icons.fastfood,
                                size: 60, color: Colors.grey),
                        title: Text(itemName),
                        subtitle: Text('Price: Rs. $price'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () =>
                                  decreaseQuantity(cartItems.indexOf(item)),
                              icon: const Icon(Icons.remove, color: Colors.red),
                            ),
                            Text(quantity.toString()),
                            IconButton(
                              onPressed: () =>
                                  increaseQuantity(cartItems.indexOf(item)),
                              icon: const Icon(Icons.add, color: Colors.green),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Rs. ${calculateTotalPrice()}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: navigateToPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Pay Rs. ${calculateTotalPrice().toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/home');
          if (index == 1) Navigator.pushReplacementNamed(context, '/favorites');
          if (index == 3) Navigator.pushReplacementNamed(context, '/profile');
        },
      ),
    );
  }
}
