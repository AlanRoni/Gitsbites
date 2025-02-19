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
  User? currentUser = FirebaseAuth.instance.currentUser;
  double totalAmount = 0.0;

  void _updateQuantity(
      String docId, Map<String, dynamic> item, bool increase) async {
    final cartRef = FirebaseFirestore.instance
        .collection('trial database')
        .doc(currentUser?.uid)
        .collection('cart')
        .doc(docId);

    int currentQuantity = item['quantity'] ?? 1;

    if (!increase && currentQuantity <= 1) {
      // Delete item if quantity would become 0
      await cartRef.delete();
    } else {
      // Update quantity
      await cartRef.update({
        'quantity': increase ? currentQuantity + 1 : currentQuantity - 1,
      });
    }
  }

  Future<void> _clearCart() async {
    final cartRef = FirebaseFirestore.instance
        .collection('trial database')
        .doc(currentUser?.uid)
        .collection('cart');

    final cartItems = await cartRef.get();

    // Delete all items in cart using batch
    final batch = FirebaseFirestore.instance.batch();
    for (var doc in cartItems.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  void _proceedToPayment(List<Map<String, dynamic>> cartItems) async {
    if (totalAmount > 0) {
      // Convert the cart items to the format expected by PaymentPage
      List<Map<String, dynamic>> formattedItems = cartItems
          .map((item) => {
                'name': item['Item_Name'],
                'price': item['Price'],
                'quantity': item['quantity'],
                'imageURL': item['imageURL'] ?? '',
              })
          .toList();

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentPage(
            totalAmount:
                (totalAmount / 2).round(), // Fix the double counting issue
            cartItems: formattedItems,
            userName: currentUser?.displayName ?? 'Guest',
            userEmail: currentUser?.email ?? 'No Email',
          ),
        ),
      );

      // If payment was successful (PaymentPage returns true)
      if (result == true) {
        await _clearCart(); // Clear the cart after successful payment
      }
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
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('trial database')
                .doc(currentUser?.uid)
                .collection('cart')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    "Your cart is empty!",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              final cartItems = snapshot.data!.docs;
              totalAmount = 0.0;

              // Convert Firestore documents to List<Map>
              final List<Map<String, dynamic>> cartItemsList =
                  cartItems.map((doc) {
                final item = doc.data() as Map<String, dynamic>;
                final itemTotal =
                    (item['Price'] ?? 0) * (item['quantity'] ?? 1);
                totalAmount += itemTotal;
                return {
                  ...item,
                  'id': doc.id, // Include document ID
                };
              }).toList();

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item =
                            cartItems[index].data() as Map<String, dynamic>;
                        final itemTotal =
                            (item['Price'] ?? 0) * (item['quantity'] ?? 1);
                        totalAmount += itemTotal;

                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            leading: item['imageURL'] != null
                                ? Image.network(
                                    item['imageURL'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.fastfood),
                            title: Text(item['Item_Name'] ?? 'Unknown Item'),
                            subtitle: Row(
                              children: [
                                Text('Price: ₹${item['Price']}'),
                                const Spacer(),
                                // Quantity Controls
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: Colors.red,
                                  onPressed: () => _updateQuantity(
                                      cartItems[index].id, item, false),
                                ),
                                Text(
                                  '${item['quantity'] ?? 1}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  color: Colors.green,
                                  onPressed: () => _updateQuantity(
                                      cartItems[index].id, item, true),
                                ),
                              ],
                            ),
                            trailing: Text(
                              '₹${(item['Price'] ?? 0) * (item['quantity'] ?? 1)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      },
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total: ₹${totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _proceedToPayment(cartItemsList),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            'Pay ₹${totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
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

  void _removeFromCart(String docId) async {
    await FirebaseFirestore.instance
        .collection('trial database')
        .doc(currentUser?.uid)
        .collection('cart')
        .doc(docId)
        .delete();
  }
}
