import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl package for date formatting

class PreOrderPage extends StatelessWidget {
  const PreOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the selected date passed as an argument
    final DateTime selectedDate =
        ModalRoute.of(context)!.settings.arguments as DateTime;

    // Format the date to only show the date (day, month, year)
    final formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pre-Order', style: TextStyle(color: Colors.white)),
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
                // Display the formatted date only (without time)
                Text(
                  'Selected Pre-Order Date: $formattedDate',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
                const SizedBox(height: 20), // Space between text and buttons
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
