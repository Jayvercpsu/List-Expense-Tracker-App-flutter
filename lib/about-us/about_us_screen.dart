import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/all_exp_screen.dart';
import '../screens/all_expenses.dart';
import '../models/expense.dart';

class AboutUsScreen extends StatefulWidget {
  final List<Expense> expenses;
  final Function(Expense) editExpense;
  final Function(String) deleteExpense;

  AboutUsScreen({
    required this.expenses,
    required this.editExpense,
    required this.deleteExpense,
  });

  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulates a loading delay of at least 1 second
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  // Open Facebook Profile
  void _openFacebook() async {
    final Uri url = Uri.parse("https://www.facebook.com/jayver.algadipe");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(color: Colors.blueAccent),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 App Information Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "About Expense Tracker",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Expense Tracker is a simple yet powerful app designed to help users manage their daily expenses efficiently. "
                        "Keep track of your spending, filter expenses by date, and even attach images to transactions.",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // 🔹 Developer Contact Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Developer Contact",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.email, color: Colors.blue),
                    title: const Text(
                      "jayver.cpsu@gmail.com",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.facebook, color: Colors.blue),
                    title: const Text(
                      "Facebook: @jayver.algadipe",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    onTap: _openFacebook,
                  ),
                  ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.blue),
                    title: const Text(
                      "Philippines",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Copyright Information
            Center(
              child: const Text(
                "Developed by J-ALDEV © 2025",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ],
        ),
      ),

      // 🔹 Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
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
                  expenses: widget.expenses,
                  editExpense: widget.editExpense,
                  deleteExpense: widget.deleteExpense,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
