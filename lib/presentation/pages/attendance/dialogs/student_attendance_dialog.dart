// Flutter imports:
// Project imports:
import 'package:attendance_log_with_firebase/core/domain/models/student.dart';
import 'package:attendance_log_with_firebase/presentation/pages/attendance/widgets/student_attendance_chart.dart';

// Package imports:
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentAttendanceDialog extends StatelessWidget {
  final String fio;
  final String id;
  final DateFormat format;
  final DateTime endDate;
  final DateTime startDate;
  final List<AttendanceForGroupAndSubject>? attendance;

  const StudentAttendanceDialog({
    super.key,
    required this.fio,
    required this.id,
    required this.format,
    required this.endDate,
    required this.startDate,
    required this.attendance,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(
        '$fio\n(${format.format(startDate)} - ${format.format(endDate)})',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: Colors.black,
        ),
      ),
      children: <Widget>[
        if (attendance != null && (attendance?.isNotEmpty ?? false))
          SizedBox(
            width: 200.0,
            height: 300.0,
            child: _findStudentStates(id, startDate, endDate),
          )
        else
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Информации о посещаемости студента за выбранный временной промежуток не найдено',
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  StudentAttendanceChart _findStudentStates(
    studentId,
    funcStartDate,
    funcEndDate,
  ) {
    final DateFormat formatCompare = DateFormat('y-MM-dd');

    int state1 = 0;
    int state2 = 0;
    int state3 = 0;
    for (final element in attendance!) {
      final date = formatCompare.parse(element.date);
      if (date.isAfter(funcStartDate) && date.isBefore(funcEndDate) ||
          date.isAtSameMomentAs(startDate) ||
          date.isAtSameMomentAs(endDate)) {
        element.attendanceMap.forEach((id, state) {
          if (id == studentId) {
            if (state == 'Присутствовал') state1 += 1;
            if (state == 'Уважительная причина') state2 += 1;
            if (state == 'Неуважительная причина') state3 += 1;
          }
        });
      }
    }
    final data = [
      StudentStates(
        typeState: 'Присутствовал',
        countStates: state1,
        color: const charts.Color(r: 0, g: 204, b: 0),
      ),
      StudentStates(
        typeState: 'Уважительная причина',
        countStates: state2,
        color: const charts.Color(r: 255, g: 153, b: 51),
      ),
      StudentStates(
        typeState: 'Неуважительная причина',
        countStates: state3,
        color: const charts.Color(r: 255, g: 0, b: 0),
      ),
    ];
    return StudentAttendanceChart.withSampleData(data);
  }
}
