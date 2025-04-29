import 'package:expanse_traker/core/entities/expense.dart';
import 'package:expanse_traker/core/repositories/message_repository.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';

class MessageRepositoryImpl implements MessageRepository {
  final SmsQuery _query = SmsQuery();

  Expense? parseMessageToExpense(SmsMessage sms) {
    String body = sms.body ?? '';
    DateTime date = sms.date ?? DateTime.now();

    // Basic parsing for demonstration - improve this logic
    double? amount;
    String type = '';

    // Example: Look for "debited" or "credited" keywords and extract amount
    if (body.contains('debited')) {
      type = 'debit';
      RegExp exp = RegExp(r"debited by (\d+(\.\d+)?)");
      RegExpMatch? match = exp.firstMatch(body);
      if (match != null && match.groupCount >= 1) {
        amount = double.tryParse(match.group(1) ?? '');
      }
    } else if (body.contains('credited')) {
      type = 'credit';
      RegExp exp = RegExp(r"credited by (\d+(\.\d+)?)");
      RegExpMatch? match = exp.firstMatch(body);
       if (match != null && match.groupCount >= 1) {
        amount = double.tryParse(match.group(1) ?? '');
      }
    }

    if (amount != null) {
      return Expense(
        amount: amount,
        type: type,
        date: date,
        description: body,
      );
    }
    return null;
  }

   @override
  Future<List<Expense>> getAllExpenses() async {
    var permission = await Permission.sms.request();
    if (permission.isGranted || permission.isLimited) {
      List<SmsMessage> messages = await _query.getAllSms;
      List<Expense> expenses = [];
      for (SmsMessage sms in messages) {
        Expense? expense = parseMessageToExpense(sms);
        if (expense != null) {
          expenses.add(expense);
        }
      }
      return expenses;
    } else {
      throw Exception("SMS permission not granted");
    }
  }
  
}
