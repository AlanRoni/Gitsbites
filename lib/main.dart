import 'package:flutter/material.dart';
import 'package:gitsbites/breakfast.dart';
import 'package:gitsbites/lunch.dart';
import 'package:gitsbites/cart_page.dart';
import 'package:gitsbites/profile_page.dart';
import 'package:gitsbites/favorites_page.dart';
import 'package:gitsbites/bottom_nav.dart';
import 'package:gitsbites/payment.dart';
import 'package:gitsbites/preorder1.dart';
import 'package:table_calendar/table_calendar.dart'; // Import table_calendar package
import 'package:firebase_core/firebase_core.dart';
import 'dart:typed_data'; // Import dart:typed_data package
import 'package:gitsbites/login.dart'; // Add this import for the login page
import 'package:gitsbites/google_pay_page.dart'; // Add this import for Google Pay page
import 'package:gitsbites/order_placed_page.dart'; // Add this import for Order Placed page
import 'package:gitsbites/admin.dart';
import 'package:gitsbites/admin_menu.dart';
import 'package:gitsbites/admin_pending_orders.dart';

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

  runApp(const MyApp());
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
        '/login': (context) => const LoginPage(), // Define route for login page
        '/home': (context) => const HomePage(),
        '/favorites': (context) => const FavoritesPage(),
        '/cart': (context) => const CartPage(),
        '/profile': (context) => const ProfilePage(),
        '/payment': (context) =>
            const PaymentPage(totalAmount: 0, cartItems: []),
        '/preorder': (context) => const PreOrderPage(),
        '/breakfast': (context) => const BreakfastPage(),
        '/lunch': (context) => const LunchPage(),
        '/google_pay': (context) =>
            const GooglePayPage(), // Add GooglePayPage route
        '/order_placed': (context) => OrderPlacedPage(
            receiptPdf: Uint8List(0)), // Add OrderPlacedPage route
        '/admin': (context) => const AdminPage(), // Admin Dashboard
        '/admin_menu': (context) => const AdminMenuPage(), // Admin Menu Page
        '/admin_pending_orders': (context) =>
            const AdminPendingOrdersPage(), // Admin Pending Orders Page
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Function to show the Date Picker with custom calendar
  Future<void> _selectPreOrderDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();

    // Show the custom calendar with gradient background
    final DateTime? selectedDate = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            height: 400,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE3F4E7), Color(0xFFA8D5A3)], // Soft gradient
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TableCalendar(
              focusedDay: currentDate,
              firstDay: DateTime(currentDate.year, 1, 1),
              lastDay: DateTime(currentDate.year + 1, 12, 31),
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
              },
              enabledDayPredicate: (day) {
                // Disable dates before today
                return day
                    .isAfter(currentDate.subtract(const Duration(days: 1)));
              },
              onDaySelected: (selectedDay, focusedDay) {
                Navigator.of(context).pop(selectedDay);
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                rightChevronIcon:
                    Icon(Icons.chevron_right, color: Colors.white),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Colors.green.shade700),
                weekendStyle: TextStyle(color: Colors.green.shade900),
              ),
            ),
          ),
        );
      },
    );

    // If the user selects a date, navigate to PreOrder page with the selected date
    if (selectedDate != null) {
      Navigator.pushNamed(
        context,
        '/preorder',
        arguments:
            selectedDate, // Pass selected date as an argument to PreOrderPage
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
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
                      _selectPreOrderDate(
                          context); // Show date picker before redirecting
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
                const SizedBox(height: 20), // Spacing between buttons
                // Login Button
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
                          context, '/login'); // Navigate to Login Page
                    },
                    child: const Text(
                      'LOGIN',
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
