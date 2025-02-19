
import 'package:flutter/material.dart';

class GooglePayPage extends StatelessWidget {
  const GooglePayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Pay'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/google_pay_qr.png', // Replace with your Google Pay QR code image
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            const Text(
              'Scan the QR code to complete the payment.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
