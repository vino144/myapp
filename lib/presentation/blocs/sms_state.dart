import 'package:equatable/equatable.dart';
import 'package:myapp/core/entities/message.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SmsState extends Equatable {
  const SmsState();
  @override
  List<Object?> get props => [];
}

class SmsLoading extends SmsState {}
class SmsLoaded extends SmsState { final List<Message> messages; const SmsLoaded({required this.messages}); @override List<Object?> get props => [messages];} class SmsError extends SmsState { final String message; const SmsError({required this.message}); @override List<Object?> get props => [message]; }