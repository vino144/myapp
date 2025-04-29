import 'package:expanse_traker/core/entities/expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../blocs/sms_bloc.dart';

class ExpanseListScreen extends StatefulWidget {
  const ExpanseListScreen({super.key});

  @override
  State<ExpanseListScreen> createState() => _ExpanseListScreenState();
}

class _ExpanseListScreenState extends State<ExpanseListScreen> {
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    var status = await Permission.sms.status;
    if (!status.isGranted) {
      status = await Permission.sms.request();
    }
    if (status.isGranted) {
    } else {
      // Handle if permission is denied permanently
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('SMS permission denied')));
    }
  }

  Widget _buildBody(BuildContext context, SmsState state) {
    if (state is SmsLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is SmsLoaded) {
      if (state.expenses.isEmpty) {
        return const Center(child: Text('No expenses found.'));
      }
      return ListView.builder(
        itemCount: state.expenses.length,
        itemBuilder: (context, index) {
          Expense expense = state.expenses[index];
          IconData icon = Icons.question_mark;
          if(expense.type == "credit"){
            icon = Icons.arrow_upward;
          }else if (expense.type == "debit"){
            icon = Icons.arrow_downward;
          }
          return ListTile(
            leading: Icon(icon),
            title: Row(
              children: [
                const Icon(Icons.currency_rupee),
                Text('${expense.amount}'),
              ],
            ),
            subtitle: Text('${expense.type}'),
            trailing: Text('${expense.date.day}-${expense.date.month}-${expense.date.year}'),
          );
        },
      );
    } else if (state is SmsError) {
      return Center(child: Text('Error: ${state.message}'));
    } else {
      return const Center(child: Text('No SMS messages found.'));
    } 
  }

  @override
  Widget build(BuildContext context) {
    context.read<SmsBloc>().add(LoadSms());
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Expense List'),
      ),
      body: BlocConsumer<SmsBloc, SmsState>(
        builder: (context, state) {
          return _buildBody(context, state);
        },
        listener: (context, state) {
          if (state is SmsError) {
            print("Error: ${state.message}");
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
        },
      ),
    );
  }
}

