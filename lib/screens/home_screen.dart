import 'package:flutter/material.dart';
import 'package:list_expenses/models/expense.dart';
import 'all_expenses.dart';
import 'reports.dart';
import 'package:list_expenses/widgets/expense_dialog.dart';
import 'homepage.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Expense> _expenses = [];
  int _selectedIndex = 0;

  final List<Widget> _pages = [];

  final Map<String, List<Expense>> _expenseCategories = {
    'Palit Bayad': [],
    'Palit Sud-an': [],
    'Others': [],
  };

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      HomePage(
        expenses: _expenses,
        deleteExpense: _deleteExpense,
        calculateTotalExpenses: _calculateTotalExpenses,
      ),
      AllExpensesPage(expenses: _expenses, onDelete: (expenseId) => _deleteExpense(expenseId)),
      ReportsPage(expenseCategories: _expenseCategories),
    ]);
  }

  void _addExpense(String title, double amount, String category) {
    final newExpense = Expense(
      id: DateTime.now().toString(),
      title: title,
      amount: amount, // Convert to PHP
      date: DateTime.now(),
      type: category,
    );

    setState(() {
      _expenses.add(newExpense);
      _expenseCategories[category]?.add(newExpense);
    });
  }

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AddExpenseDialog(_addExpense),
        ),
      ),
    );
  }

  void _deleteExpense(String expenseId) {
    setState(() {
      _expenses.removeWhere((expense) => expense.id == expenseId); // Removes the expense by id
    });
  }

  double _calculateTotalExpenses() {
    double total = 0;
    for (var expense in _expenses) {
      total += expense.amount;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Center(
                child: Text(
                  'Expense Tracker',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.blueAccent),
              title: Text('Home', style: TextStyle(fontSize: 18)),
              onTap: () {
                setState(() => _selectedIndex = 0);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.list, color: Colors.blueAccent),
              title: Text('All Expenses', style: TextStyle(fontSize: 18)),
              onTap: () {
                setState(() => _selectedIndex = 1);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.pie_chart, color: Colors.blueAccent),
              title: Text('Reports', style: TextStyle(fontSize: 18)),
              onTap: () {
                setState(() => _selectedIndex = 2);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blueAccent,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'All Expenses'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Reports'),
        ],
      ),
    );
  }
}
