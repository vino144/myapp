import 'package:expanse_traker/core/usecases/get_all_sms.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'sms_event.dart';
import 'sms_state.dart';

export 'sms_event.dart';
export 'sms_state.dart';


class SmsBloc extends Bloc<SmsEvent, SmsState> {
  final GetAllExpenses getAllExpenses;

  SmsBloc({required this.getAllExpenses}) : super(SmsLoading()) {
    on<LoadSms>((event, emit) async {
      emit(SmsLoading());
      try {
        final expenses = await getAllExpenses.call();
        emit(SmsLoaded(expenses: expenses));
      } catch (e) {
        emit(SmsError(message: e.toString()));
      }
    });
  }
}
