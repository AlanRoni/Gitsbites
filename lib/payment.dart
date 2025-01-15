import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedPaymentMethod = 'card'; // Default selection
  String _selectedUPIApp = 'googlePay'; // Default UPI option
  String _upiId = ''; // Store entered UPI ID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50, // Light green background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title and Amount
              Text(
                'Payment Summary',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20.0),
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  children: [
                    Text(
                      '£500.00',
                      style: TextStyle(
                        fontSize: 36.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      'Goods and Services\nRef: 554732223687',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30.0),

              // Payment Method Section
              Text(
                'Choose Payment Method',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 10.0),

              // Credit/Debit Card Option
              _buildPaymentOption(
                title: 'Credit or Debit Card',
                value: 'card',
                isSelected: _selectedPaymentMethod == 'card',
                child: _selectedPaymentMethod == 'card'
                    ? Column(
                        children: [
                          _buildTextField('Card Number'),
                          const SizedBox(height: 10.0),
                          Row(
                            children: [
                              Expanded(
                                  child:
                                      _buildTextField('Expiry Date (MM/YY)')),
                              const SizedBox(width: 10.0),
                              Expanded(child: _buildTextField('CVV')),
                            ],
                          ),
                        ],
                      )
                    : null,
              ),

              // UPI Option
              _buildPaymentOption(
                title: 'UPI',
                value: 'upi',
                isSelected: _selectedPaymentMethod == 'upi',
                child: _selectedPaymentMethod == 'upi'
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select UPI App',
                            style: TextStyle(
                                fontSize: 16.0, color: Colors.black87),
                          ),
                          _buildRadioOption('Google Pay', 'googlePay'),
                          _buildRadioOption('PhonePe', 'phonePe'),
                          _buildRadioOption('Other', 'other'),
                          if (_selectedUPIApp == 'other')
                            const SizedBox(height: 10.0),
                          if (_selectedUPIApp == 'other')
                            _buildTextField('Enter UPI ID'),
                        ],
                      )
                    : null,
              ),

              // Cash on Delivery Option
              _buildPaymentOption(
                title: 'Cash on Delivery',
                value: 'cash',
                isSelected: _selectedPaymentMethod == 'cash',
              ),

              const Spacer(),

              // Proceed Button
              ElevatedButton(
                onPressed: () {
                  if (_selectedPaymentMethod == 'card') {
                    print('Processing Card Payment');
                  } else if (_selectedPaymentMethod == 'upi') {
                    if (_selectedUPIApp == 'other' && _upiId.isEmpty) {
                      print('Enter a valid UPI ID');
                    } else {
                      print('Processing UPI Payment');
                    }
                  } else if (_selectedPaymentMethod == 'cash') {
                    print('Cash on Delivery Selected');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Proceed to Pay',
                  style: TextStyle(fontSize: 18.0, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to build payment options
  Widget _buildPaymentOption({
    required String title,
    required String value,
    required bool isSelected,
    Widget? child,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade200 : Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? Colors.green.shade600 : Colors.green.shade200,
            width: 2.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.green.shade100,
                    blurRadius: 8.0,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade800,
              ),
            ),
            if (child != null) const SizedBox(height: 10.0),
            if (child != null) child,
          ],
        ),
      ),
    );
  }

  // Helper to build text fields
  Widget _buildTextField(String label) {
    return TextField(
      onChanged: (value) {
        if (label == 'Enter UPI ID') {
          setState(() {
            _upiId = value;
          });
        }
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  // Helper to build UPI radio options
  Widget _buildRadioOption(String title, String value) {
    return ListTile(
      leading: Radio<String>(
        value: value,
        groupValue: _selectedUPIApp,
        onChanged: (String? value) {
          setState(() {
            _selectedUPIApp = value!;
          });
        },
        activeColor: Colors.green,
      ),
      title: Text(title, style: const TextStyle(color: Colors.black87)),
    );
  }
}
