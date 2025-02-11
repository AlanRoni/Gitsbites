import 'package:flutter/material.dart';

class PreOrderPage extends StatelessWidget {
  const PreOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pre-Order', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Color(0xFFA8D5A3)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGreenButton(context, "Breakfast"),
                const SizedBox(height: 20),
                _buildGreenButton(context, "Lunch"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreenButton(BuildContext context, String label) {
    return SizedBox(
      width: 200, // Fixed width for uniform size
      height: 60, // Fixed height for uniform size
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green, // Solid green color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$label selected")),
          );
        },
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white, // White text for contrast
          ),
        ),
      ),
    );
  }
}
