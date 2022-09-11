part of 'date_picker_bloc.dart';

@immutable
class DatePickerState {
  final DateTime? startDate;
  final DateTime? endDate;

  const DatePickerState({this.startDate, this.endDate});

  DatePickerState copyWith({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return DatePickerState(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
