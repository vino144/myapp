import 'package:expanse_traker/core/usecases/get_all_sms.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'sms_event.dart';
import 'sms_state.dart';

export 'sms_event.dart';
export 'sms_state.dart';


class SmsBloc extends Bloc<SmsEvent, SmsState> {
  final GetAllExpenses getAllExpenses;

  SmsBloc({required this.getAllExpenses}) : super(SmsLoading()) {
    on<LoadSms>((event, emit) async {
      debugPrint("Loading expenses");
      emit(SmsLoading());
      try {
        debugPrint("Getting all expenses");
        final expenses = await getAllExpenses.call();
        debugPrint("Expenses loaded, emitting state");
        emit(SmsLoaded(expenses: expenses));
      } catch (e) {
        debugPrint("Error loading expenses ${e.toString()}");
        emit(SmsError(message: e.toString()));
      }
    });
  }
}