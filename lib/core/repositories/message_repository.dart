import '../entities/expense.dart';

abstract class MessageRepository {
  Future<List<Expense>> getAllExpenses();
}
