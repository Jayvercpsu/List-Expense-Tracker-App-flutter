import 'package:flutter/material.dart';
import 'package:list_expenses/models/expense.dart';


class ReportsPage extends StatelessWidget {
  final Map<String, List<Expense>> expenseCategories;

  ReportsPage({required this.expenseCategories});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: expenseCategories.entries.map((entry) {
          return ExpansionTile(
            title: Text(entry.key),
            children: entry.value.map((expense) {
              return ListTile(
                title: Text(expense.title),
                subtitle: Text('${expense.date.toLocal()}'.split(' ')[0]),
                trailing: Text('₱${expense.amount.toStringAsFixed(2)}'),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}