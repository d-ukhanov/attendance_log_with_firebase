// Flutter imports:
// Project imports:
import 'package:attendance_log_with_firebase/core/domain/models/student.dart';
import 'package:attendance_log_with_firebase/core/domain/repositories/attendance_repository.dart';
import 'package:attendance_log_with_firebase/core/domain/repositories/students_repository.dart';
import 'package:attendance_log_with_firebase/presentation/pages/attendance/attendance_table.dart';
import 'package:attendance_log_with_firebase/presentation/widgets/custom_scaffold.dart';
import 'package:attendance_log_with_firebase/presentation/widgets/loading.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:get_it/get_it.dart';

class Attendance extends StatefulWidget {
  final String groupId;
  final String subjectId;
  final String subjectName;

  const Attendance({
    super.key,
    required this.groupId,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  _AttendanceState createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  late final StudentsRepository studentsRepository;
  late final AttendanceRepository attendanceRepository;

  @override
  void initState() {
    super.initState();

    studentsRepository = GetIt.I.get();
    attendanceRepository = GetIt.I.get();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: widget.subjectName,
      body: _getStudentsStreamBuilder(
        attendanceStreamBuilder: (students) {
          return _getAttendanceStreamBuilder(
            attendanceTableWidget: (attendance) {
              return _getAttendanceTableWidget(students, attendance);
            },
          );
        },
      ),
    );
  }

  Widget _getStudentsStreamBuilder({
    required Widget Function(List<Student>) attendanceStreamBuilder,
  }) {
    return StreamBuilder<List<Student>?>(
      stream: studentsRepository.studentsForGroup(widget.groupId),
      builder: (context, studentsSnap) {
        if (studentsSnap.connectionState == ConnectionState.waiting) {
          return Loading();
        }

        if (studentsSnap.hasData && (studentsSnap.data?.isNotEmpty ?? false)) {
          return attendanceStreamBuilder(studentsSnap.data!);
        }

        return const SizedBox();
      },
    );
  }

  Widget _getAttendanceStreamBuilder({
    required Widget Function(List<AttendanceForGroupAndSubject>?)
        attendanceTableWidget,
  }) {
    return StreamBuilder<List<AttendanceForGroupAndSubject>?>(
      stream: attendanceRepository.attendanceForGroupAndSubject(
        widget.groupId,
        widget.subjectId,
      ),
      builder: (context, attendanceSnap) {
        if (attendanceSnap.connectionState == ConnectionState.waiting) {
          return Loading();
        }

        return attendanceTableWidget(attendanceSnap.data);
      },
    );
  }

  Widget _getAttendanceTableWidget(
    List<Student> students,
    List<AttendanceForGroupAndSubject>? attendance,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: AttendanceTable(
          groupId: widget.groupId,
          subjectId: widget.subjectId,
          students: students,
          attendance: attendance,
        ),
      ),
    );
  }
}
