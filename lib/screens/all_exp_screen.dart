import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:list_expenses/models/expense.dart';
import 'all_expenses.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:list_expenses/widgets/expense_dialog.dart';

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
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? expenseList = prefs.getStringList('expenses');
    if (expenseList != null) {
      setState(() {
        _expenses.clear();
        _expenses.addAll(expenseList.map((e) => Expense.fromJson(e)));
        _filteredExpenses = List.from(_expenses);
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
      _filteredExpenses = _expenses;
    });

    _saveExpenses();
  }

  void _editExpense(Expense updatedExpense) {
    setState(() {
      int index = _expenses.indexWhere((exp) => exp.id == updatedExpense.id);
      if (index != -1) {
        _expenses[index] = updatedExpense;
        _filteredExpenses = _expenses;
      }
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
        final matchesTitle =
        expense.title.toLowerCase().contains(query.toLowerCase());
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
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
        iconTheme: IconThemeData(color: Colors.white), // ✅ Ensures all icons are white
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // ✅ Back arrow set to white
          onPressed: () {
            Navigator.pop(context); // ✅ Navigates back when pressed
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.date_range, color: Colors.white), // ✅ Date picker icon set to white
            onPressed: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                _filterByDate(picked);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.clear, color: Colors.white), // ✅ Clear (X) icon set to white
            onPressed: _clearFilters,
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by title...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _searchExpenses,
            ),
          ),
          Expanded(
            child: _filteredExpenses.isEmpty
                ? Center(
              child: Text(
                'No expenses found!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: _filteredExpenses.length,
              itemBuilder: (ctx, index) {
                final expense = _filteredExpenses[index];
                return Card(
                  margin: EdgeInsets.symmetric(
                      vertical: 8, horizontal: 16),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                      DateFormat('yyyy-MM-dd HH:mm').format(expense.date),
                      style: TextStyle(color: Colors.grey),
                    ),
                    trailing: Text(
                      '₱${expense.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'All Expenses'),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AllExpensesPage(
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
