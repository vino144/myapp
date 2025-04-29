import '../entities/expense.dart';
import '../repositories/message_repository.dart';

class GetAllExpenses {
  final MessageRepository messageRepository;

  GetAllExpenses(this.messageRepository);

  Future<List<Expense>> call() async {
    return await messageRepository.getAllExpenses();
  }
}