import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  // Dummy data for cart items
  final List<Map<String, dynamic>> cartItems = [
    {
      "name": "Lentil Fritters",
      "price": 10,
      "quantity": 2,
      "image": "assets/item1.png", // Replace with actual image paths
    },
    {
      "name": "Chicken Fried Rice",
      "price": 150,
      "quantity": 2,
      "image": "assets/item2.png",
    },
    {
      "name": "Stringhoppers",
      "price": 10,
      "quantity": 2,
      "image": "assets/item3.png",
    },
    {
      "name": "Chocolate Milkshake",
      "price": 90,
      "quantity": 2,
      "image": "assets/item1.png",
    },
  ];

  // Function to calculate total price
  int calculateTotalPrice() {
    int total = 0;
    for (var item in cartItems) {
      total += (item['price'] as int) *
          (item['quantity'] as int); // Ensure both are int
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: () {
              // Handle cart item deletion
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // List of cart items
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        // Item image
                        Image.asset(
                          item["image"],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 10),

                        // Item details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["name"],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text("INR ${item['price']}"),
                            ],
                          ),
                        ),

                        // Quantity selector
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                // Decrease quantity
                              },
                            ),
                            Text(item["quantity"].toString()),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                // Increase quantity
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Total and Payment button section
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Column(
              children: [
                // Total amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Rs. ${calculateTotalPrice()}",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                // Payment button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {
                      // Navigate to payment page
                    },
                    child: Text(
                      "Go to Payment",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        currentIndex: 2, // Set default selected index to Cart
        onTap: (index) {
          // Handle bottom navigation tap
        },
      ),
    );
  }
}
