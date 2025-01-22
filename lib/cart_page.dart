import 'package:flutter/material.dart';
import 'bottom_nav.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final List<Map<String, dynamic>> cartItems = [
    {
      "name": "Lentil Fritters",
      "price": 10,
      "quantity": 2,
      "image": "assets/item1.png",
    },
    {
      "name": "Chicken Fried Rice",
      "price": 150,
      "quantity": 2,
      "image": "assets/item2.png",
    },
  ];

  final List<bool> isHovered = [];

  @override
  void initState() {
    super.initState();
    isHovered.addAll(List<bool>.generate(cartItems.length, (_) => false));
  }

  int calculateTotalPrice() {
    int total = 0;
    for (var item in cartItems) {
      total += (item['price'] as int) * (item['quantity'] as int);
    }
    return total;
  }

  void increaseQuantity(int index) {
    setState(() {
      cartItems[index]['quantity']++;
    });
  }

  void decreaseQuantity(int index) {
    setState(() {
      if (cartItems[index]['quantity'] > 1) {
        cartItems[index]['quantity']--;
      } else {
        cartItems.removeAt(index);
        isHovered.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'Cart',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.shopping_cart,
              size: 24,
              color: Colors.white,
            ),
          ],
        ),
        backgroundColor: Colors.green,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                cartItems.clear();
                isHovered.clear();
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/cart_background.png', // Replace with your background image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Gradient and Main Content
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Color.fromARGB(255, 198, 241, 193)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return MouseRegion(
                        onEnter: (_) {
                          setState(() {
                            isHovered[index] = true;
                          });
                        },
                        onExit: (_) {
                          setState(() {
                            isHovered[index] = false;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          transform: isHovered[index]
                              ? Matrix4.diagonal3Values(1.02, 1.02, 1.0)
                              : Matrix4.identity(),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: isHovered[index]
                                ? [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    )
                                  ]
                                : [
                                    BoxShadow(
                                      color: Colors.grey.shade300,
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    item["image"],
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item["name"],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "INR ${item['price']}",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove,
                                          color: Colors.redAccent),
                                      onPressed: () {
                                        decreaseQuantity(index);
                                      },
                                    ),
                                    Text(
                                      item["quantity"].toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.add, color: Colors.green),
                                      onPressed: () {
                                        increaseQuantity(index);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 168, 230, 161),
                        Colors.white
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                          Text(
                            "Rs. ${calculateTotalPrice()}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            // Navigate to payment page
                            Navigator.pushNamed(context, '/payment');
                          },
                          child: const Text(
                            "Go to Payment",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 2,
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
