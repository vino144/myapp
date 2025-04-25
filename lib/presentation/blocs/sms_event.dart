import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart'; 
abstract class SmsEvent extends Equatable { const SmsEvent(); @override List<Object?> get props => [];} 

class LoadSms extends SmsEvent {}