import 'package:flutter/material.dart';
import '../screens/all_exp_screen.dart';
import '../screens/all_expenses.dart';
import '../models/expense.dart';

class AboutUsScreen extends StatelessWidget {
  final List<Expense> expenses;
  final Function(Expense) editExpense;
  final Function(String) deleteExpense;

  AboutUsScreen({
    required this.expenses,
    required this.editExpense,
    required this.deleteExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "About Expense Tracker",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            SizedBox(height: 10),
            Text(
              "Expense Tracker is a simple yet powerful app designed to help users manage their daily expenses efficiently. "
                  "Keep track of your spending, filter expenses by date, and even attach images to transactions.",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            SizedBox(height: 30),
            Text(
              "Developer Contact",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.email, color: Colors.blue),
              title: Text("jayver.cpsu@gmail.com", style: TextStyle(fontSize: 16, color: Colors.black87)),
            ),
            ListTile(
              leading: Icon(Icons.location_on, color: Colors.blue),
              title: Text("Philippines", style: TextStyle(fontSize: 16, color: Colors.black87)),
            ),
          ],
        ),
      ),

      // ✅ Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // ✅ Since we are on the About Us page
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'All Expenses'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About Us'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomeScreen()));
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AllExpensesPage(
                  expenses: expenses, // ✅ Now we pass actual data
                  editExpense: editExpense,
                  deleteExpense: deleteExpense,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
