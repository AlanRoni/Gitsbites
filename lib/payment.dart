import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html;

class PaymentPage extends StatefulWidget {
  final int totalAmount;
  final List<Map<String, dynamic>> cartItems;

  const PaymentPage({
    super.key,
    required this.totalAmount,
    required this.cartItems,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Secure Payment',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 4.0,
        shadowColor: Colors.grey.shade300,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // **Payment Summary Card**
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.1),
                      blurRadius: 10.0,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      'Rs. ${widget.totalAmount}',
                      style: TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    // **Ordered Items List**
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.cartItems
                          .map(
                            (item) => Text(
                              "${item['name']} x${item['quantity']} - Rs. ${item['price'] * item['quantity']}",
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black54),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 10.0),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline, size: 16, color: Colors.grey),
                        SizedBox(width: 5),
                        Text(
                          'Transaction ID: #554732223687',
                          style:
                              TextStyle(fontSize: 14.0, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30.0),

              // **Payment Methods Heading**
              const Text(
                'Select Payment Method',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15.0),

              // **Payment Methods**
              Column(
                children: [
                  _buildPaymentMethod(
                    icon: Icons.account_balance_wallet,
                    title: "Google Pay",
                    subtitle: "Pay securely via Google Pay",
                    color: Colors.blue.shade600,
                    onTap: () {
                      print('Pay via Google Pay');
                    },
                  ),
                  const SizedBox(height: 12.0),
                  _buildPaymentMethod(
                    icon: Icons.money,
                    title: "Cash on Delivery",
                    subtitle: "Pay with cash upon delivery",
                    color: Colors.green.shade700,
                    onTap: () async {
                      await _generateReceipt(
                          widget.totalAmount, widget.cartItems);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 35.0),

              // **Confirm Payment Button**
              GestureDetector(
                onTap: () {
                  print('Payment Confirmed');
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.green, Colors.greenAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8.0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Confirm Payment',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // **Reusable Payment Method Card**
  Widget _buildPaymentMethod({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.1),
              blurRadius: 6.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              radius: 22,
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 15.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13.0, color: Colors.black54),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // **Generate Receipt PDF**
  Future<void> _generateReceipt(
      int amount, List<Map<String, dynamic>> cartItems) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text("Payment Receipt",
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text("Transaction ID: #554732223687",
                style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 10),
            pw.Text("Payment Method: Cash on Delivery",
                style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 10),
            pw.Text("Total Amount: Rs. $amount",
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text("Purchased Items:",
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            ...cartItems.map((item) => pw.Text(
                "${item['name']} x${item['quantity']} - Rs. ${item['price'] * item['quantity']}")),
            pw.SizedBox(height: 20),
            pw.Text("Thank you for your purchase!",
                style: pw.TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );

    final Uint8List pdfBytes = await pdf.save();

    if (kIsWeb) {
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', 'receipt.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }
}
