import 'package:flutter/material.dart';
import 'screens/all_exp_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // ✅ Removes the debug banner
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(), // Initial screen: SplashScreen
    );
  }
}
