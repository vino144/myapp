import 'package:equatable/equatable.dart';
import 'package:expanse_traker/core/entities/expense.dart';

class SmsState extends Equatable {
  const SmsState();
  @override
  List<Object?> get props => [];
}

class SmsLoading extends SmsState {}

class SmsLoaded extends SmsState {  final List<Expense> expenses;
  const SmsLoaded({required this.expenses});
  @override
  List<Object?> get props => [expenses];
}

class SmsError extends SmsState {
  final String message;
  const SmsError({required this.message});
  @override
  List<Object?> get props => [message];
}
