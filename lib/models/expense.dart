          import 'dart:convert';

          class Expense {
            String id;
            String _title;
            double _amount;
            DateTime date;
            String? imagePath; // ✅ Optional image path

            Expense({
              required this.id,
              required String title,
              required double amount,
              required this.date,
              this.imagePath, // ✅ Make it optional
            })  : _title = title,
                  _amount = amount;

            // Getters
            String get title => _title;
            double get amount => _amount;

            // Setters
            set title(String newTitle) {
              _title = newTitle;
            }

            set amount(double newAmount) {
              _amount = newAmount;
            }

            // Convert Expense to JSON
            String toJson() {
              final data = {
                'id': id,
                'title': _title,
                'amount': _amount,
                'date': date.toIso8601String(),
                'imagePath': imagePath, // ✅ Store image path
              };
              return json.encode(data);
            }

            // Convert JSON to Expense
            factory Expense.fromJson(String jsonString) {
              final data = json.decode(jsonString);
              return Expense(
                id: data['id'],
                title: data['title'],
                amount: data['amount'],
                date: DateTime.parse(data['date']),
                imagePath: data['imagePath'], // ✅ Retrieve image path
              );
            }

            // Copy with method for immutability-friendly updates
            Expense copyWith({
              String? id,
              String? title,
              double? amount,
              DateTime? date,
            }) {
              return Expense(
                id: id ?? this.id,
                title: title ?? _title,
                amount: amount ?? _amount,
                date: date ?? this.date,
              );
            }
          }
