import 'package:expanse_traker/core/entities/expense.dart';
import 'package:expanse_traker/core/repositories/message_repository.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';

class MessageRepositoryImpl implements MessageRepository {
  final SmsQuery _query = SmsQuery();


  List<Expense> parseMessageToExpense(SmsMessage sms) {
  String body = sms.body ?? '';
  DateTime date = sms.date ?? DateTime.now();
  List<Expense> expenses = [];

  print('parseMessageToExpense - SMS Body: $body');

  // More flexible regex for debit messages, with amount at the start or the end.
  RegExp debitExp = RegExp(r"(\d+)");
    
  
  final debitMatches = debitExp.allMatches(body);
  print('parseMessageToExpense - Debit Matches: $debitMatches');

  for (final debitMatch in debitMatches) {
    String amountStr = debitMatch.group(1)?.replaceAll(",", "") ?? '';

    print('parseMessageToExpense - amountStr: $amountStr');
    print("parseMessageToExpense - amountStr is empty ${amountStr?.isEmpty}");


    double? amount = double.tryParse(amountStr);

    print("parseMessageToExpense - amount: $amount");

    if (amount != null) {
      print('parseMessageToExpense - Extracted Expense: {amount: $amount, type: debit}');

        expenses.add(Expense(amount: amount, type: 'debit', date: date, description: body,));
    } else {
      print('parseMessageToExpense - No debit expense created');
    }
  }

  // More flexible regex for credit messages, with amount at the start or the end.
  RegExp creditExp = RegExp(
    r"(?:credited|received|deposit|credit|refund).*(?:rs\.?|inr\.?|amount|)([\\d,]+\\.?\\d*)|([\\d,]+\\.?\\d*).*(?:credited|received|deposit|credit|refund)",
      caseSensitive: false,
    );    
  final creditMatches = creditExp.allMatches(body);
  print('parseMessageToExpense - Credit Matches: $creditMatches');

  for (final creditMatch in creditMatches) {
    String amountStr = creditMatch.group(1)?.replaceAll(",", "") ?? '';
    print('parseMessageToExpense - amountStr: $amountStr');
    print("parseMessageToExpense - amountStr is empty ${amountStr.isEmpty}");
    double? amount = double.tryParse(amountStr);
    print("parseMessageToExpense - amount: $amount");
    if (amount != null) {
      print('parseMessageToExpense - Extracted Expense: {amount: $amount, type: credit}');

      expenses.add(Expense(amount: amount, type: 'credit', date: date, description: body,));
    } else {
      print('parseMessageToExpense - No credit expense created');
    }
  }

    if(expenses.isEmpty){
        print('parseMessageToExpense - No expense found');
    }
    return expenses;
  }
  

  @override
  Future<List<Expense>> getAllExpenses() async {
    print("getAllExpenses - Starting getAllExpenses");

    var permission = await Permission.sms.request();

    if (permission.isGranted || permission.isLimited) {
      List<SmsMessage> messages = await _query.getAllSms;
      print("getAllExpenses - Number of messages read: ${messages.length}");

      DateTime now = DateTime.now();
      DateTime lastMonthStart = DateTime(now.year, now.month - 1, 1);
      DateTime lastMonthEnd = DateTime(now.year, now.month, 0);

      List<Expense> allExpenses = [];
      for (SmsMessage message in messages) {
        allExpenses.addAll(parseMessageToExpense(message));
      }

      List<Expense> lastMonthExpenses = allExpenses.where((expense) {
        return expense.date.isAfter(lastMonthStart) &&
            expense.date.isBefore(lastMonthEnd);
      }).toList();

      // Get the Firebase instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Upload expenses to Firebase
      for (Expense expense in lastMonthExpenses) {
        await firestore.collection('expenses').add({
          'amount': expense.amount,
          'type': expense.type,
          'date': expense.date,
          'description': expense.description,
        });
      }
      return lastMonthExpenses;

    } else {
      throw Exception("SMS permission not granted");
    }
  }

}
