import 'package:flutter/material.dart';
import 'dart:typed_data';

class OrderPlacedPage extends StatelessWidget {
  final Uint8List receiptPdf;

  const OrderPlacedPage({super.key, required this.receiptPdf});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Placed'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              'Order Placed Successfully!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Handle receipt download
              },
              child: const Text('Download Receipt'),
            ),
          ],
        ),
      ),
    );
  }
}