import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'cart_page.dart'; // Import the CartPage
import 'payment.dart'; // Import the PaymentPage
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyADtVWJBi-zIy2gWDggIN9tHvPJ8NROHK0",
            authDomain: "gitsbites.firebaseapp.com",
            projectId: "gitsbites",
            storageBucket: "gitsbites.firebasestorage.app",
            messagingSenderId: "524013313932",
            appId: "1:524013313932:web:7c4d7b341ce9bea77880a9",
            measurementId: "G-C5LB4FV54D"));
  } else {
    await Firebase.initializeApp();
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Navigation Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Button to navigate to ProfilePage
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
              child: Text('Go to Profile'),
            ),
            SizedBox(height: 20), // Space between buttons

            // Button to navigate to CartPage
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartPage()),
                );
              },
              child: Text('Go to Cart'),
            ),
            SizedBox(height: 20), // Space between buttons

            // Button to navigate to PaymentPage
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaymentPage()),
                );
              },
              child: Text('Go to Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
