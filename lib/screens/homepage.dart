import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

class HomePage extends StatefulWidget {
  final List<Expense> expenses;
  final Function(String) deleteExpense;
  final Function(String, double) addExpense;
  final double Function() calculateTotalExpenses;

  HomePage({
    required this.expenses,
    required this.deleteExpense,
    required this.addExpense,
    required this.calculateTotalExpenses,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? expenseList = prefs.getStringList('expenses');
    if (expenseList != null) {
      setState(() {
        widget.expenses.clear();
        widget.expenses.addAll(
          expenseList.map((expenseStr) => Expense.fromJson(expenseStr)),
        );
      });
    }
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> expenseList =
    widget.expenses.map((expense) => expense.toJson()).toList();
    await prefs.setStringList('expenses', expenseList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Expenses: ₱${NumberFormat('#,##0.00').format(widget.calculateTotalExpenses())}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: widget.expenses.length,
                itemBuilder: (ctx, index) {
                  final expense = widget.expenses[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    elevation: 5,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        expense.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      subtitle: Text(
                        DateFormat('yyyy-MM-dd').format(expense.date),
                        style: TextStyle(color: Colors.grey),
                      ),
                      trailing: Text(
                        '₱${NumberFormat('#,##0.00').format(expense.amount)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onLongPress: () {
                        widget.deleteExpense(expense.id);
                        setState(() {
                          widget.expenses.removeAt(index);
                          _saveExpenses();
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
