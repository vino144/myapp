import 'package:expanse_traker/core/entities/expense.dart';
import 'package:expanse_traker/core/repositories/message_repository.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';

class MessageRepositoryImpl implements MessageRepository {
  final SmsQuery _query = SmsQuery();

  List<Expense> parseMessageToExpense(SmsMessage sms) {
    String body = sms.body ?? '';
    DateTime date = sms.date ?? DateTime.now();
    List<Expense> expenses = [];

    // More flexible regex for debit messages
    RegExp debitExp = RegExp(
        r"(?:debited|spent|paid|withdrawn|purchase|transfer|txn)\s*(?:of|by|for|rs\.?|inr\.?)\s*([\d,]+\.?\d*)",
        caseSensitive: false);
    final debitMatches = debitExp.allMatches(body);
    for (final debitMatch in debitMatches) {
      String amountStr = debitMatch.group(1)?.replaceAll(",", "") ?? "";
      double? amount = double.tryParse(amountStr);
      if (amount != null) {
        expenses.add(Expense(
            amount: amount, type: 'debit', date: date, description: body));
      }
    }

    // More flexible regex for credit messages
    RegExp creditExp = RegExp(
        r"(?:credited|received|deposit|credit)\s*(?:of|by|for|rs\.?|inr\.?)\s*([\d,]+\.?\d*)",
        caseSensitive: false);
    final creditMatches = creditExp.allMatches(body);
    for (final creditMatch in creditMatches) {
      String amountStr = creditMatch.group(1)?.replaceAll(",", "") ?? "";
      double? amount = double.tryParse(amountStr);
      if (amount != null) {
        expenses.add(Expense(
            amount: amount, type: 'credit', date: date, description: body));
      }
    }
    return expenses;
  }

  @override
  Future<List<Expense>> getAllExpenses() async {
    var permission = await Permission.sms.request();
    List<Expense> expenses = [];
    if (permission.isGranted || permission.isLimited) {
      List<SmsMessage> messages = await _query.getAllSms;
      for (SmsMessage sms in messages) {
        List<Expense> messageExpenses = parseMessageToExpense(sms);
        
        expenses.addAll(messageExpenses);
        
      }
      return expenses;
    } else {
      throw Exception("SMS permission not granted");
    }
  }
  
}
