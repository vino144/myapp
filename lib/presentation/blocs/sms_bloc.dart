import 'package:flutter_bloc/flutter_bloc.dart';

export 'sms_event.dart';
export 'sms_state.dart';

import 'sms_event.dart';
import 'sms_state.dart';
import '../../core/usecases/get_all_sms.dart';

class SmsBloc extends Bloc<SmsEvent, SmsState> {
  final GetAllSms getAllSms;

  SmsBloc({required this.getAllSms}) : super(SmsLoading()) {
    on<LoadSms>((event, emit) async {
      emit(SmsLoading());
      try {
        final messages = await getAllSms.call();
        emit(SmsLoaded(messages: messages));
      } catch (e) {
        emit(SmsError(message: e.toString()));
      }
    });
  }
}