import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  final double amount;
  final String type; // 'credit' or 'debit'
  final DateTime date;
  final String? description;

  const Expense({
    required this.amount,
    required this.type,
    required this.date,
    this.description,
  });
  
  @override
  List<Object?> get props => [amount, type, date, description];
}