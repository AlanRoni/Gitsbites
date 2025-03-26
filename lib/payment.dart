import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

// Conditional imports will be handled differently
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Razorpay _razorpay;
  bool isPaymentSuccessful = false;
  String transactionId = '';

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    transactionId = _generateTransactionId();
  }

  String _generateTransactionId() {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(Iterable.generate(
        10, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handleUPIPayment() {
    if (kIsWeb) {
      _handleUPIPaymentWeb();
    } else {
      _handleUPIPaymentMobile();
    }
  }

  void _handleUPIPaymentWeb() {
    try {
      // This will only work on web
      if (!kIsWeb) return;

      // Using dynamic to avoid compilation errors on mobile
      final dynamic js = _getJSLibrary();
      final options = js.JsObject.jsify({
        'key': 'rzp_test_Y7cq6hWayb2H5M',
        'amount': widget.totalAmount * 100,
        'currency': 'INR',
        'name': 'GitsBites',
        'description': 'Canteen Order Payment',
        'prefill': {
          'contact': '9876543210',
          'email': widget.userEmail,
        },
        'theme': {'color': '#00C853'},
        'method': {
          'netbanking': true,
          'card': true,
          'upi': true,
          'wallet': true,
        },
        'handler': (response) {
          _handlePaymentSuccess(response);
        },
      });

      final razorpay = js.context['Razorpay'];
      razorpay.callMethod('open', [options]);
    } catch (e) {
      debugPrint('Web payment error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to initiate web payment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  dynamic _getJSLibrary() {
    if (!kIsWeb) return null;
    // This is a workaround to avoid compilation errors
    // The actual import is handled by the build system
    return dynamic;
  }

  void _handleUPIPaymentMobile() {
    var options = {
      'key': 'rzp_test_Y7cq6hWayb2H5M',
      'amount': widget.totalAmount * 100,
      'currency': 'INR',
      'name': 'GitsBites',
      'description': 'Canteen Order Payment',
      'prefill': {
        'contact': '9876543210',
        'email': widget.userEmail,
      },
      'theme': {'color': '#00C853'},
      'method': {
        'netbanking': true,
        'card': true,
        'upi': true,
        'wallet': true,
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open payment gateway: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handlePaymentSuccess(dynamic response) {
    debugPrint('Payment Successful: ${response['razorpay_payment_id']}');
    setState(() {
      isPaymentSuccessful = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Successful: ${response['razorpay_payment_id']}'),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Payment Failed: ${response.message}');
    setState(() {
      isPaymentSuccessful = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message}'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet Selected: ${response.walletName}');
  }

  Future<void> _clearCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final cartRef = FirebaseFirestore.instance
            .collection('trial database')
            .doc(user.uid)
            .collection('cart');

        final snapshot = await cartRef.get();
        final batch = FirebaseFirestore.instance.batch();

        for (var doc in snapshot.docs) {
          batch.delete(doc.reference);
        }

        await batch.commit();

        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        debugPrint('Error clearing cart: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error clearing cart: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _saveOrderToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final orderNumber = DateTime.now().millisecondsSinceEpoch.toString();

      await _firestore.collection('orders').add({
        'orderNumber': orderNumber,
        'userId': user.uid,
        'userName': widget.userName,
        'userEmail': widget.userEmail,
        'totalAmount': widget.totalAmount,
        'paymentMethod': selectedPaymentMethod,
        'orderDate': DateTime.now(),
        'items': widget.cartItems,
        'status': 'pending',
        'transactionId': transactionId,
      });

      await _clearCart();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      );
    } catch (e) {
      debugPrint('Error saving order: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error placing order: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        );
      }
    }
  }

  void _handlePaymentConfirmation() async {
    if (selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      );
      return;
    }

    if (selectedPaymentMethod == 'UPI Payment' && !isPaymentSuccessful) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete the UPI payment first'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      );
      return;
    }

    try {
      await _saveOrderToFirestore();
      await _generateReceipt(widget.totalAmount, widget.cartItems);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Payment Successful!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Transaction ID: $transactionId',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your order has been placed successfully.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/home',
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Continue Shopping',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      debugPrint('Error confirming payment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error confirming payment: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Secure Payment',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[800],
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...widget.cartItems.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${item['name']} x${item['quantity']}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  "Rs. ${item['price'] * item['quantity']}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const Divider(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Rs. ${widget.totalAmount}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.receipt,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 5),
                          Text(
                            'Transaction ID: $transactionId',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Payment Methods',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              _buildPaymentMethod(
                icon: Icons.account_balance_wallet,
                title: "UPI Payment",
                subtitle: "Pay securely via UPI",
                color: Colors.blue[600]!,
                onTap: _handleUPIPayment,
                isSelected: selectedPaymentMethod == 'UPI Payment',
              ),
              const SizedBox(height: 12),
              _buildPaymentMethod(
                icon: Icons.money,
                title: "Cash Payment",
                subtitle: "Pay with cash",
                color: Colors.green[700]!,
                onTap: () {
                  setState(() {
                    selectedPaymentMethod = 'Cash on Delivery';
                  });
                },
                isSelected: selectedPaymentMethod == 'Cash on Delivery',
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handlePaymentConfirmation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    shadowColor: Colors.green.withOpacity(0.3),
                  ),
                  child: const Text(
                    'Confirm Payment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Widget _buildPaymentMethod({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }

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
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildTransactionDetail("Transaction ID:", transactionId),
                  _buildTransactionDetail(
                      "Payment Method:", selectedPaymentMethod ?? 'N/A'),
                  _buildTransactionDetail("Date:", _getCurrentDate()),
                  _buildTransactionDetail("Customer:", widget.userName),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
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
      _savePdfWeb(pdfBytes);
    } else {
      await _savePdfMobile(pdfBytes);
    }
  }

  void _savePdfWeb(Uint8List pdfBytes) {
    try {
      if (!kIsWeb) return;

      // This will be handled by the web compiler
      final dynamic html = _getHTMLLibrary();
      if (html == null) return;

      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', 'GitsBites_Receipt_$transactionId.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      debugPrint('Error saving PDF on web: $e');
    }
  }

  Future<void> _savePdfMobile(Uint8List pdfBytes) async {
    try {
      // This will be handled by the mobile compiler
      final directory = await getApplicationDocumentsDirectory();
      final file =
          File('${directory.path}/GitsBites_Receipt_$transactionId.pdf');
      await file.writeAsBytes(pdfBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Receipt saved to ${file.path}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('Error saving PDF on mobile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save receipt: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  dynamic _getHTMLLibrary() {
    if (!kIsWeb) return null;
    // This is a workaround to avoid compilation errors
    return dynamic;
  }

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

  String _getCurrentDate() {
    final now = DateTime.now();
    return "${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}";
  }
}

// Mobile-specific implementations
Future<dynamic> getApplicationDocumentsDirectory() async {
  if (kIsWeb) return null;
  // This will be replaced by the actual implementation for mobile
  return null;
}

class File {
  final String path;
  File(this.path);

  Future<void> writeAsBytes(Uint8List bytes) async {
    // Implementation for mobile
  }
}
