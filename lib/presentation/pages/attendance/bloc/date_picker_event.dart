part of 'date_picker_bloc.dart';

@immutable
abstract class DatePickerEvent {}

class ChangeDateEvent extends DatePickerEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  ChangeDateEvent({this.startDate, this.endDate});
}
