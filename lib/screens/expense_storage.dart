import 'package:shared_preferences/shared_preferences.dart';
import 'package:list_expenses/models/expense.dart';
import 'dart:convert'; // Import for JSON encoding/decoding

class ExpenseStorage {
  final String _key = 'expenses'; // Key for SharedPreferences storage

  // Save expenses to shared preferences
  Future<void> saveExpenses(List<Expense> expenses) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> expenseStrings = expenses.map((e) => e.toJson()).toList(); // Use toJson()
    await prefs.setStringList(_key, expenseStrings);
  }

  // Load expenses from shared preferences
  Future<List<Expense>> loadExpenses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? expenseStrings = prefs.getStringList(_key);
    if (expenseStrings == null) return [];

    return expenseStrings.map((e) => Expense.fromJson(e)).toList(); // Use fromJson()
  }
}
