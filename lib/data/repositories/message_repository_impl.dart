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

  print('SMS Body: $body');

  // More flexible regex for debit messages, with amount at the start or the end.
  RegExp debitExp = RegExp(
    r"(?:debited|spent|paid|withdrawn|purchase|transfer|txn|payment).*(?:rs\.?|inr\.?|amount|)([\\d,]+\\.?\\d*)|([\\d,]+\\.?\\d*).*(?:debited|spent|paid|withdrawn|purchase|transfer|txn|payment)",
    caseSensitive: false,
  );
  final debitMatches = debitExp.allMatches(body);
  print('Debit Matches: $debitMatches');

  for (final debitMatch in debitMatches) {
    String amountStr = debitMatch.group(1)?.replaceAll(",", "") ?? "";
    if (amountStr == "") {
      amountStr = debitMatch.group(2)?.replaceAll(",", "") ?? "";
    }
    double? amount = double.tryParse(amountStr);
    if (amount != null) {
      expenses.add(Expense(
        amount: amount,
        type: 'debit',
        date: date,
        description: body,
      ));
      print('Extracted Expense: {amount: $amount, type: debit}');
    }
  }

  // More flexible regex for credit messages, with amount at the start or the end.
  RegExp creditExp = RegExp(
    r"(?:credited|received|deposit|credit|refund).*(?:rs\.?|inr\.?|amount|)([\\d,]+\\.?\\d*)|([\\d,]+\\.?\\d*).*(?:credited|received|deposit|credit|refund)",
    caseSensitive: false,
  );
  final creditMatches = creditExp.allMatches(body);
  print('Credit Matches: $creditMatches');
  for (final creditMatch in creditMatches) {
    String amountStr = creditMatch.group(1)?.replaceAll(",", "") ?? "";
    if (amountStr == "") {
      amountStr = creditMatch.group(2)?.replaceAll(",", "") ?? "";
    }
    double? amount = double.tryParse(amountStr);
    if (amount != null) {
      expenses.add(Expense(
        amount: amount,
        type: 'credit',
        date: date,
        description: body,
      ));
      print('Extracted Expense: {amount: $amount, type: credit}');
      }
    }
    if(expenses.isEmpty){
        print('No expense found');
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
