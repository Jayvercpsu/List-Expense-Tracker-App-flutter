import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:list_expenses/models/expense.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'all_exp_screen.dart'; // Import HomeScreen

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

  void _confirmDeleteExpense(BuildContext context, String expenseId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
    final _editAmountController =
    TextEditingController(text: expense.amount.toString());

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    expense.title = _editTitleController.text.trim();
                    expense.amount =
                        double.tryParse(_editAmountController.text) ?? 0;
                    widget.editExpense(expense);
                  });
                  Navigator.of(ctx).pop();
                  _saveExpenses();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Expense updated!')),
                  );
                },
                child: const Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> expenseList =
    widget.expenses.map((expense) => expense.toJson()).toList();
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
        iconTheme: IconThemeData(color: Colors.white), // ✅ Makes back arrow white
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
            onPressed: () {
              setState(() {
                _searchController.clear();
                _selectedDate = null;
                _filteredExpenses = List.from(widget.expenses);
              });
            },
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
          Container(
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Expenses:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                Text(
                  '₱${_calculateTotalExpenses().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredExpenses.length,
              itemBuilder: (context, index) {
                final expense = _filteredExpenses[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(expense.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                    subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(expense.date), style: TextStyle(color: Colors.grey)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () => _showEditExpenseDialog(context, expense)),
                        IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmDeleteExpense(context, expense.id)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'All Expenses'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
          }
        },
      ),
    );
  }
}
