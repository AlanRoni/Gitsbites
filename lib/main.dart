import 'package:flutter/material.dart';
import 'package:gitsbites/breakfast.dart';
import 'package:gitsbites/lunch.dart';
import 'package:firebase_core/firebase_core.dart';
import 'cart_page.dart';
import 'profile_page.dart';
import 'favorites_page.dart';
import 'bottom_nav.dart';
import 'payment.dart';
import 'preorder1.dart';
import 'login.dart'; // Add this import for the login page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyADtVWJBi-zIy2gWDggIN9tHvPJ8NROHK0',
      authDomain: 'gitsbites.firebaseapp.com',
      projectId: 'gitsbites',
      storageBucket: 'gitsbites.firebasestorage.app',
      messagingSenderId: '524013313932',
      appId: '1:524013313932:web:7c4d7b341ce9bea77880a9',
      measurementId: 'G-C5LB4FV54D',
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Kioski App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        initialRoute: '/login', // Set initial route to '/login'
        routes: {
          '/login': (context) =>
              const LoginPage(), // Define route for login page
          '/home': (context) => const HomePage(),
          '/favorites': (context) => const FavoritesPage(),
          '/cart': (context) => const CartPage(),
          '/profile': (context) => const ProfilePage(),
          '/payment': (context) =>
              const PaymentPage(totalAmount: 0, cartItems: []),
          '/preorder': (context) => const PreOrderPage(),
          '/breakfast': (context) => const BreakfastPage(),
          '/lunch': (context) => const LunchPage(),
        });
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Home logo
            Icon(
              Icons.home, // Using the home icon for the logo
              size: 24, // Adjust the size of the logo
              color: Colors.white,
            ),
            const SizedBox(width: 8), // Space between the logo and title
            const Text('Home', style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          // Background Gradient
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
                // Breakfast Button
                SizedBox(
                  width: 200, // Ensures both buttons have the same size
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                          context, '/breakfast'); // Navigate to Breakfast Page
                    },
                    child: const Text(
                      'BREAKFAST',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Spacing between buttons
                // Lunch Button
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                          context, '/lunch'); // Navigate to Lunch Page
                    },
                    child: const Text(
                      'LUNCH',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Spacing between buttons
                // Pre-Order Button
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 76, 175, 80),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                          context, '/preorder'); // Navigate to PreOrderPage
                    },
                    child: const Text(
                      'PRE-ORDER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/favorites');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/cart');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }
}
