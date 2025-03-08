import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:list_expenses/models/expense.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'all_exp_screen.dart';
import 'view_image_screen.dart';
import 'package:list_expenses/about-us/about_us_screen.dart';
import 'all_exp_screen.dart';

class AllExpensesPage extends StatefulWidget {
  final List<Expense> expenses;
  final Function(Expense) editExpense;
  final Function(String) deleteExpense;

  AllExpensesPage({
    required this.expenses,
    required this.editExpense,
    required this.deleteExpense,
  });

  @override
  _AllExpensesPageState createState() => _AllExpensesPageState();
}

class _AllExpensesPageState extends State<AllExpensesPage> {
  List<Expense> _filteredExpenses = [];
  final TextEditingController _searchController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _filteredExpenses = List.from(widget.expenses);
  }

  void _searchExpenses(String query) {
    setState(() {
      _filteredExpenses = widget.expenses.where((expense) {
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

  void _confirmDeleteExpense(BuildContext context, String expenseId) {
    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            title: Text('Confirm Delete'),
            content: Text('Are you sure you want to delete this expense?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Cancel', style: TextStyle(color: Colors.blue)),
              ),
              TextButton(
                onPressed: () {
                  widget.deleteExpense(expenseId);
                  setState(() {
                    _filteredExpenses.removeWhere((exp) => exp.id == expenseId);
                  });
                  _saveExpenses();
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Expense deleted!')),
                  );
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _showEditExpenseDialog(BuildContext context, Expense expense) {
    final _editTitleController = TextEditingController(text: expense.title);
    final _editAmountController = TextEditingController(
        text: expense.amount.toString());
    String? _selectedImagePath = expense.imagePath;

    Future<void> _pickImage() async {
      final pickedFile = await ImagePicker().pickImage(
          source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImagePath = pickedFile.path;
        });
      }
    }

    showDialog(
      context: context,
      builder: (ctx) =>
          Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _editTitleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      labelStyle: TextStyle(color: Colors.blue),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _editAmountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount (in PHP)',
                      labelStyle: TextStyle(color: Colors.blue),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                  ),
                  const SizedBox(height: 16),

                  // Image preview and picker
                  _selectedImagePath != null
                      ? Column(
                    children: [
                      Image.file(
                        File(_selectedImagePath!),
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                      TextButton(
                        onPressed: _pickImage,
                        child: Text('Change Image',
                            style: TextStyle(color: Colors.blue)),
                      ),
                    ],
                  )
                      : TextButton(
                    onPressed: _pickImage,
                    child: Text(
                        'Upload Image', style: TextStyle(color: Colors.blue)),
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        expense.title = _editTitleController.text.trim();
                        expense.amount =
                            double.tryParse(_editAmountController.text) ?? 0;
                        expense.imagePath = _selectedImagePath;
                        widget.editExpense(expense);
                      });
                      Navigator.of(ctx).pop();
                      _saveExpenses();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Expense updated!')),
                      );
                    },
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> expenseList = widget.expenses.map((expense) =>
        expense.toJson()).toList();
    await prefs.setStringList('expenses', expenseList);
  }

  double _calculateTotalExpenses() {
    return _filteredExpenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Expenses', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
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
          IconButton(
            icon: Icon(Icons.clear, color: Colors.white),
            onPressed: () =>
                setState(() {
                  _searchController.clear();
                  _selectedDate = null;
                  _filteredExpenses = List.from(widget.expenses);
                }),
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
                    borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: _searchExpenses,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredExpenses.length,
              itemBuilder: (context, index) {
                final expense = _filteredExpenses[index];
                return ListTile(
                  title: Text(expense.title),
                  subtitle: Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(expense.date)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () =>
                              _showEditExpenseDialog(context, expense)),
                      IconButton(icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _confirmDeleteExpense(context, expense.id)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Keeps the selected tab on "All Expenses"
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
              context, MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AboutUsScreen(
                  expenses: widget.expenses, // ✅ Now passing expenses correctly
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