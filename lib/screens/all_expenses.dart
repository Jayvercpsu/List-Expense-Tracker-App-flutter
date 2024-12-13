import 'package:flutter/material.dart';
import 'package:list_expenses/models/expense.dart';

class AllExpensesPage extends StatelessWidget {
  final List<Expense> expenses;
  final Function(String) onDelete;

  AllExpensesPage({required this.expenses, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          final expense = expenses[index];
          return ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              expense.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            subtitle: Text(
              '${expense.date.toLocal()}'.split(' ')[0],
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '₱${expense.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditExpenseDialog(context, expense);
                    } else if (value == 'delete') {
                      onDelete(
                          expense.id); // Pass the id to the onDelete function
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Expense deleted!')),
                      );
                    }
                  },
                  itemBuilder: (context) =>
                  [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  void _showEditExpenseDialog(BuildContext context, Expense expense) {
    final _editTitleController = TextEditingController(text: expense.title);
    final _editAmountController = TextEditingController(
        text: expense.amount.toString());
    final _editCategoryController = TextEditingController(text: expense.type);

    showDialog(
      context: context,
      builder: (ctx) =>
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
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
                    TextField(
                      controller: _editCategoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category',
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
                    ElevatedButton(
                      onPressed: () {
                        expense.title = _editTitleController.text.trim();
                        expense.amount =
                            double.tryParse(_editAmountController.text) ?? 0;
                        expense.type = _editCategoryController.text.trim();

                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Changes saved!')),
                        );
                        // Trigger a refresh if necessary (e.g., using a callback)
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
          ),
    );
  }
}
