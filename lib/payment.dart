import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedPaymentMethod = 'card';
  String _selectedAccountType = 'personal';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20.0),
              // Amount Display
              Text(
                '£500.00',
                style: TextStyle(
                  fontSize: 36.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5.0),
              // Goods and Services
              const Text(
                'Goods and Services\nRef: 554732223687',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40.0),

              // Pay With Section in Green Container
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Pay with',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20.0),
                    // Payment Options
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            leading: Radio<String>(
                              value: 'card',
                              groupValue: _selectedPaymentMethod,
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedPaymentMethod = value!;
                                });
                              },
                              activeColor: Colors.green,
                            ),
                            title: const Text('Credit or Debit card'),
                          ),
                        ),
                        const Image(
                          image: AssetImage('assets/visa.jpg'),
                          height: 20,
                          width: 50,
                        ),
                        const SizedBox(width: 5),
                      ],
                    ),
                    ListTile(
                      leading: Radio<String>(
                        value: 'bank',
                        groupValue: _selectedPaymentMethod,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedPaymentMethod = value!;
                          });
                        },
                        activeColor: Colors.green,
                      ),
                      title: const Text('Pay by Bank'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),

              // Bank Selection
              const Text(
                'Bank',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 10.0),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'BARCLAYS',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Icon(Icons.edit, color: Colors.grey),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),

              // Account Type
              const Text(
                'Account type',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 10.0),
              Column(
                children: [
                  ListTile(
                    leading: Radio<String>(
                      value: 'personal',
                      groupValue: _selectedAccountType,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedAccountType = value!;
                        });
                      },
                      activeColor: Colors.green,
                    ),
                    title: const Text('Personal'),
                  ),
                  ListTile(
                    leading: Radio<String>(
                      value: 'business',
                      groupValue: _selectedAccountType,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedAccountType = value!;
                        });
                      },
                      activeColor: Colors.green,
                    ),
                    title: const Text('Business'),
                  ),
                ],
              ),
              const Spacer(),

              // Select Button
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Select',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
