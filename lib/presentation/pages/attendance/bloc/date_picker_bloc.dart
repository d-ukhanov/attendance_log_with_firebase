import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'date_picker_event.dart';

part 'date_picker_state.dart';

class DatePickerBloc extends Bloc<DatePickerEvent, DatePickerState> {
  DatePickerBloc() : super(const DatePickerState()) {
    on<ChangeDateEvent>(
      (event, emit) => emit(
        state.copyWith(
          startDate: event.startDate,
          endDate: event.endDate,
        ),
      ),
    );
  }
}
