import 'package:flutter/material.dart';
import 'package:list_expenses/models/expense.dart';

class AllExpensesPage extends StatefulWidget {
  final List<Expense> expenses;
  final Function(String) onDelete;

  AllExpensesPage({required this.expenses, required this.onDelete});

  @override
  _AllExpensesPageState createState() => _AllExpensesPageState();
}

class _AllExpensesPageState extends State<AllExpensesPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: ListView.builder(
        itemCount: widget.expenses.length,
        itemBuilder: (context, index) {
          final expense = widget.expenses[index];
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
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    widget.onDelete(expense.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Expense deleted!')),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
