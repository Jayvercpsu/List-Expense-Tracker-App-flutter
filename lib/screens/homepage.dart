import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

class HomePage extends StatelessWidget {
  final List<Expense> expenses;
  final Function(String) deleteExpense;
  final double Function() calculateTotalExpenses;

  HomePage({
    required this.expenses,
    required this.deleteExpense,
    required this.calculateTotalExpenses,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Expenses: ₱${NumberFormat('#,##0.00').format(calculateTotalExpenses())}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (ctx, index) {
                  final expense = expenses[index];
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
                        // Display amount as PHP without conversion
                        '₱${NumberFormat('#,##0.00').format(expense.amount)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onLongPress: () {
                        deleteExpense(expense.id);
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
