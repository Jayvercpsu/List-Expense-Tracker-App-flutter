import 'package:flutter/material.dart';
import 'package:list_expenses/models/expense.dart';
import 'all_expenses.dart';
import 'package:list_expenses/widgets/expense_dialog.dart';
import 'homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Expense> _expenses = [];
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
    _initializePages();
  }

  void _initializePages() {
    _pages = [
      HomePage(
        expenses: _expenses,
        addExpense: _addExpense,
        deleteExpense: _deleteExpense,
        calculateTotalExpenses: _calculateTotalExpenses,
      ),
      AllExpensesPage(
        expenses: _expenses,
        onDelete: (expenseId) => _deleteExpense(expenseId),
      ),
    ];
  }

  Future<void> _loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? expenseList = prefs.getStringList('expenses');

    if (expenseList != null) {
      setState(() {
        _expenses.clear();
        _expenses.addAll(expenseList.map((e) => Expense.fromJson(e)));
        _initializePages(); // Reinitialize pages to reflect changes
      });
    }
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> expenseList = _expenses.map((e) => e.toJson()).toList();
    await prefs.setStringList('expenses', expenseList);
  }

  void _addExpense(String title, double amount) {
    final newExpense = Expense(
      id: DateTime.now().toString(),
      title: title,
      amount: amount,
      date: DateTime.now(),
    );

    setState(() {
      _expenses.add(newExpense);
      _initializePages(); // Update UI instantly
    });

    _saveExpenses(); // Save expenses persistently
  }

  void _deleteExpense(String expenseId) {
    setState(() {
      _expenses.removeWhere((expense) => expense.id == expenseId);
      _initializePages(); // Update UI instantly
    });

    _saveExpenses(); // Save updated expenses
  }

  double _calculateTotalExpenses() {
    return _expenses.fold(0, (sum, expense) => sum + expense.amount);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
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
        ],
      ),
    );
  }
}
