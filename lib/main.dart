import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'intro.dart'; // Add this line
// Pages
import 'package:gitsbites/breakfast.dart';
import 'package:gitsbites/lunch.dart';
import 'package:gitsbites/cart_page.dart';
import 'package:gitsbites/profile_page.dart';
import 'package:gitsbites/favorites_page.dart';
import 'package:gitsbites/bottom_nav.dart';
import 'package:gitsbites/payment.dart';
import 'package:gitsbites/preorder1.dart';
import 'package:gitsbites/login.dart';
import 'package:gitsbites/admin.dart';
import 'package:gitsbites/admin_pending_orders.dart';
import 'package:gitsbites/admin_menu.dart';
import 'admin_login.dart';
import 'admin_home.dart'; // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    name: 'gitsbites',
    options: const FirebaseOptions(
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
      title: 'GitsBites',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const IntroPage(), // Set IntroPage as the home screen
      routes: {
        '/intro': (context) => const IntroPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/favorites': (context) => const FavoritesPage(),
        '/cart': (context) => const CartPage(),
        '/profile': (context) => const ProfilePage(),
        '/payment': (context) {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            return PaymentPage(
              totalAmount: 0,
              cartItems: const [],
              userName: user.displayName ?? 'Guest',
              userEmail: user.email ?? 'No Email',
            );
          } else {
            return const LoginPage();
          }
        },
        '/preorder': (context) => const PreOrderPage(),
        '/breakfast': (context) => const BreakfastPage(),
        '/lunch': (context) => const LunchPage(),
        '/admin': (context) => const AdminPage(),
        '/admin_pending_orders': (context) => const AdminPendingOrdersPage(),
        '/admin_menu': (context) => const AdminMenuPage(),
        '/admin_login': (context) => const AdminLoginPage(),
        '/admin_home': (context) => const AdminHomePage(), // Add this route
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
                leftChevronIcon:
                    const Icon(Icons.chevron_left, color: Colors.white),
                rightChevronIcon:
                    const Icon(Icons.chevron_right, color: Colors.white),
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
        title: const Row(
          children: [
            Icon(
              Icons.home, // Using the home icon for the logo
              size: 24, // Adjust the size of the logo
              color: Colors.white,
            ),
            SizedBox(width: 8), // Space between the logo and title
            Text('Home', style: TextStyle(color: Colors.white)),
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
