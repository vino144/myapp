import '../entities/message.dart';
import '../repositories/message_repository.dart';

class GetAllSms {
  final MessageRepository messageRepository;

  GetAllSms(this.messageRepository);

  Future<List<Message>> call() async {
    return await messageRepository.getAllSms();
  }
}