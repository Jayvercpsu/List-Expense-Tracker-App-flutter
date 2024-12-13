class Expense {
  final String id;
  String title;  // Remove `late`
  double amount;  // Remove `late`
  final DateTime date;
  String type;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
  });
}
