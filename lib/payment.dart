import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html;
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentPage extends StatefulWidget {
  final int totalAmount;
  final List<Map<String, dynamic>> cartItems;
  final String userName;
  final String userEmail;

  const PaymentPage({
    super.key,
    required this.totalAmount,
    required this.cartItems,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? selectedPaymentMethod;
  bool isHoveredGooglePay = false;
  bool isHoveredCOD = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
                    title: "UPI Payment",
                    subtitle: "Pay securely via UPI",
                    color: Colors.blue.shade600,
                    onTap: () {
                      setState(() {
                        selectedPaymentMethod = 'Google Pay';
                      });
                    },
                    isDisabled: selectedPaymentMethod != null &&
                        selectedPaymentMethod != 'Google Pay',
                    isHovered: isHoveredGooglePay,
                    onHover: (isHovered) {
                      setState(() {
                        isHoveredGooglePay = isHovered;
                      });
                    },
                    isSelected: selectedPaymentMethod == 'Google Pay',
                  ),
                  const SizedBox(height: 12.0),
                  _buildPaymentMethod(
                    icon: Icons.money,
                    title: "Cash Payment",
                    subtitle: "Pay with cash",
                    color: Colors.green.shade700,
                    onTap: () {
                      setState(() {
                        selectedPaymentMethod = 'Cash on Delivery';
                      });
                    },
                    isDisabled: selectedPaymentMethod != null &&
                        selectedPaymentMethod != 'Cash on Delivery',
                    isHovered: isHoveredCOD,
                    onHover: (isHovered) {
                      setState(() {
                        isHoveredCOD = isHovered;
                      });
                    },
                    isSelected: selectedPaymentMethod == 'Cash on Delivery',
                  ),
                ],
              ),

              const SizedBox(height: 35.0),

              // **Confirm Payment Button**
              GestureDetector(
                onTap: () async {
                  if (selectedPaymentMethod != null) {
                    // Generate the receipt
                    await _generateReceipt(
                        widget.totalAmount, widget.cartItems);

                    // Save order details to Firestore
                    await _saveOrderToFirestore(
                        widget.totalAmount, widget.cartItems);

                    // Show Thank You Message
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Thank You!'),
                        content: const Text('Your order has been confirmed.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close dialog
                              Navigator.pop(
                                  context); // Navigate back to home page
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Show error message if no payment method is selected
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Error'),
                        content: const Text('Please select a payment method.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close dialog
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
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

  Future<void> _saveOrderToFirestore(
      int totalAmount, List<Map<String, dynamic>> cartItems) async {
    try {
      // Create a new document in the 'user' collection
      await _firestore.collection('user').add({
        // Store the user ID to link the order to a user
        'userName': widget.userName, // Use widget.userName here
        'userEmail': widget.userEmail, // Use widget.userEmail here
        'totalAmount': totalAmount,
        'paymentMethod': selectedPaymentMethod,
        'transactionId': '#554732223687',
        'date': _getCurrentDate(),
        'items': cartItems,
      });
    } catch (e) {
      print('Error saving order to Firestore: $e');
    }
  }

  // **Reusable Payment Method Card**
  Widget _buildPaymentMethod({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isDisabled,
    required bool isHovered,
    required Function(bool) onHover,
    required bool isSelected,
  }) {
    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: GestureDetector(
        onTap: isDisabled ? null : onTap,
        child: AbsorbPointer(
          absorbing: isDisabled,
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color:
                  isHovered || isSelected ? Colors.grey.shade100 : Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: color.withOpacity(0.6),
                    blurRadius: 10.0,
                    offset: const Offset(0, 4),
                  )
                else
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.1),
                    blurRadius: 6.0,
                    offset: const Offset(0, 3),
                  ),
              ],
              border: isHovered || isSelected
                  ? Border.all(color: color, width: 2.0)
                  : null,
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
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (isSelected)
                  Icon(Icons.check_circle, color: color, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // **Generate Receipt PDF**
  // **Generate Professional Receipt PDF**
  Future<void> _generateReceipt(
      int amount, List<Map<String, dynamic>> cartItems) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // **Header**
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("GitsBites",
                        style: pw.TextStyle(
                            fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text("Payment Receipt",
                        style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey700)),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(8),
                    color: PdfColors.green,
                  ),
                  child: pw.Text("To be Paid at Counter",
                      style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            // **Transaction Details**
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildTransactionDetail("Transaction ID:", "#554732223687"),
                  _buildTransactionDetail(
                      "Payment Method:", "Cash on Delivery"),
                  _buildTransactionDetail("Date:", _getCurrentDate()),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // **Purchased Items Table**
            pw.Text("Purchased Items",
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),

            pw.SizedBox(height: 10),

            pw.Table.fromTextArray(
              headers: ["Item", "Qty", "Price (Rs)"],
              data: cartItems
                  .map((item) => [
                        item['name'],
                        item['quantity'].toString(),
                        (item['price'] * item['quantity']).toString()
                      ])
                  .toList(),
              border: pw.TableBorder.all(color: PdfColors.grey300),
              headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.green),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
                2: pw.Alignment.centerRight,
              },
            ),

            pw.SizedBox(height: 20),

            // **Total Amount**
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.green,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Total Amount",
                      style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white)),
                  pw.Text("Rs. $amount",
                      style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white)),
                ],
              ),
            ),

            pw.SizedBox(height: 30),

            // **Thank You Message**
            pw.Center(
              child: pw.Text("Thank you for shopping with GitsBites!",
                  style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700)),
            ),
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

  // **Helper Method: Build Transaction Detail Row**
  pw.Widget _buildTransactionDetail(String title, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        children: [
          pw.Text(title,
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
          pw.SizedBox(width: 8),
          pw.Text(value, style: const pw.TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  // **Helper Method: Get Current Date**
  String _getCurrentDate() {
    final now = DateTime.now();
    return "${now.day}/${now.month}/${now.year}";
  }
}
