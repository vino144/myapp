
import 'package:expanse_traker/core/entities/expense.dart';

class Message {
  final String id;
  final String sender;
  final String body;
  final DateTime date;
  final Expense? expense;
  final bool isExpense;

  Message({
    required this.id,
    required this.sender,
    required this.body,
    required this.date,
    this.expense,
    this.isExpense = false,
  });
}