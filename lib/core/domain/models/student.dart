// Package imports:
import 'package:charts_flutter/flutter.dart';

class Student {
  final String fio;
  final String studentId;

  Student({
    required this.fio,
    required this.studentId,
  });
}

class AttendanceForGroupAndSubject {
  final Map<dynamic, dynamic> attendanceMap;
  final String date;

  AttendanceForGroupAndSubject({
    required this.attendanceMap,
    required this.date,
  });
}

class StudentStates {
  final String typeState;
  final int countStates;
  final Color color;

  StudentStates({
    required this.typeState,
    required this.countStates,
    required this.color,
  });
}
