import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:list_expenses/models/expense.dart';
import 'all_expenses.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:list_expenses/widgets/expense_dialog.dart';
import 'view_image_screen.dart';
import 'package:list_expenses/about-us/about_us_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Expense> _expenses = [];
  List<Expense> _filteredExpenses = [];
  final TextEditingController _searchController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _loadExpenses();
  }

  bool _isLoading = true;

  Future<void> _loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? expenseList = prefs.getStringList('expenses');

    await Future.delayed(Duration(seconds: 1)); // Simulated loading delay

    if (expenseList != null) {
      setState(() {
        _expenses.clear();
        _expenses.addAll(expenseList.map((e) => Expense.fromJson(e)));
        _filteredExpenses = List.from(_expenses);
      });
    }

    setState(() {
      _isLoading = false; // Stop loading
    });
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> expenseList = _expenses.map((e) => e.toJson()).toList();
    await prefs.setStringList('expenses', expenseList);
  }

  void _addExpense(String title, double amount, String? imagePath) {
    final newExpense = Expense(
      id: DateTime.now().toString(),
      title: title,
      amount: amount,
      date: DateTime.now(),
      imagePath: imagePath,
    );

    setState(() {
      _expenses.add(newExpense);
      _filteredExpenses = _expenses;
    });

    _saveExpenses();
  }

  void _editExpense(Expense updatedExpense) {
    setState(() {
      int index = _expenses.indexWhere((exp) => exp.id == updatedExpense.id);
      if (index != -1) {
        _expenses[index] = updatedExpense;
      }
      _filteredExpenses = _expenses;
    });

    _saveExpenses();
  }

  void _deleteExpense(String expenseId) {
    setState(() {
      _expenses.removeWhere((expense) => expense.id == expenseId);
      _filteredExpenses = _expenses;
    });

    _saveExpenses();
  }

  void _searchExpenses(String query) {
    setState(() {
      _filteredExpenses = _expenses.where((expense) {
        final matchesTitle = expense.title.toLowerCase().contains(
            query.toLowerCase());
        final matchesDate = _selectedDate == null ||
            DateFormat('yyyy-MM-dd').format(expense.date) ==
                DateFormat('yyyy-MM-dd').format(_selectedDate!);
        return matchesTitle && matchesDate;
      }).toList();
    });
  }

  void _filterByDate(DateTime? selectedDate) {
    setState(() {
      _selectedDate = selectedDate;
      _searchExpenses(_searchController.text);
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedDate = null;
      _filteredExpenses = List.from(_expenses);
    });
  }

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (ctx) =>
          Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: AddExpenseDialog(_addExpense),
            ),
          ),
    );
  }

  void _viewImage(String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewImageScreen(imagePath: imagePath),
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
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.home, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.date_range, color: Colors.white),
            onPressed: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) _filterByDate(picked);
            },
          ),
          IconButton(icon: Icon(Icons.clear, color: Colors.white),
              onPressed: _clearFilters),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by title...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: _searchExpenses,
            ),
          ),
          Expanded(
            child: _filteredExpenses.isEmpty
                ? Center(child: Text('No expenses found!',
                style: TextStyle(fontSize: 18, color: Colors.grey)))
                : ListView.builder(
              itemCount: _filteredExpenses.length,
              itemBuilder: (ctx, index) {
                final expense = _filteredExpenses[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: expense.imagePath != null
                        ? Image.file(File(expense.imagePath!), width: 50,
                        height: 50,
                        fit: BoxFit.cover)
                        : Icon(Icons.money, size: 40, color: Colors.green),
                    title: Text(expense.title,
                        style: TextStyle(fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('yyyy-MM-dd HH:mm').format(
                            expense.date),
                            style: TextStyle(color: Colors.grey)),
                        Text('₱${expense.amount.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green)),
                        if (expense.imagePath != null)
                          TextButton(
                            onPressed: () => _viewImage(expense.imagePath!),
                            child: Text('View Image',
                                style: TextStyle(color: Colors.blue)),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blueAccent,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list), label: 'All Expenses'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About Us'),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AllExpensesPage(
                      expenses: _expenses,
                      editExpense: _editExpense,
                      deleteExpense: _deleteExpense,
                    ),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AboutUsScreen(
                      expenses: _expenses,
                      editExpense: _editExpense,
                      deleteExpense: _deleteExpense,
                    ),
              ),
            );
          }
        },
      ),
    );
  }
}