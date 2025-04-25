import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:myapp/core/entities/message.dart';
import 'package:myapp/core/repositories/message_repository.dart';
import 'package:permission_handler/permission_handler.dart';

class MessageRepositoryImpl implements MessageRepository {
  final SmsQuery _query = SmsQuery();

  @override
  Future<List<Message>> getAllSms() async {
    var permission = await Permission.sms.request();
    if (permission.isGranted || permission.isLimited) {
      List<SmsMessage> messages = await _query.getAllSms;
      return messages.map((sms) {
        return Message(
          id: sms.id.toString(),
          sender: sms.sender ?? '',
          body: sms.body ?? '',
          date: sms.date ?? DateTime.now(),
        );
      }).toList();
    } else {
      throw Exception("SMS permission not granted");
    }
  }
}