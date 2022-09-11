// Flutter imports:
// Project imports:
import 'package:attendance_log_with_firebase/core/domain/models/student.dart';
import 'package:attendance_log_with_firebase/core/domain/repositories/attendance_repository.dart';
import 'package:attendance_log_with_firebase/core/domain/repositories/students_repository.dart';
import 'package:attendance_log_with_firebase/presentation/pages/attendance/attendance_table.dart';
import 'package:attendance_log_with_firebase/presentation/pages/attendance/bloc/date_picker_bloc.dart';
import 'package:attendance_log_with_firebase/presentation/widgets/custom_scaffold.dart';
import 'package:attendance_log_with_firebase/presentation/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Package imports:
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

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
  late final DateFormat format;

  @override
  void initState() {
    super.initState();

    studentsRepository = GetIt.I.get();
    attendanceRepository = GetIt.I.get();
    format = DateFormat('y-MM-dd');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DatePickerBloc(),
      child: CustomScaffold(
        title: widget.subjectName,
        body: FutureBuilder<String>(
          future: attendanceRepository.getLastEntryDate(),
          builder: (context, lastAttendanceDateSnap) {
            if (lastAttendanceDateSnap.connectionState ==
                ConnectionState.waiting) {
              return Loading();
            }

            return _getStudentsStreamBuilder(
              attendanceStreamBuilder: (students) {
                final DateTime lastAttendanceDate =
                    (lastAttendanceDateSnap.data != null &&
                            (lastAttendanceDateSnap.data?.isNotEmpty ?? false))
                        ? format.parse(lastAttendanceDateSnap.data!)
                        : DateTime.now();

                return _getAttendanceStreamBuilder(
                  attendanceTableWidget: (
                    attendance, {
                    required DateTime startDate,
                    required DateTime endDate,
                  }) {
                    return _getAttendanceTableWidget(
                      students,
                      attendance,
                      startDate: startDate,
                      endDate: endDate,
                    );
                  },
                  lastAttendanceDate: lastAttendanceDate,
                );
              },
            );
          },
        ),
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
    required Widget Function(
      List<AttendanceForGroupAndSubject>? attendance, {
      required DateTime startDate,
      required DateTime endDate,
    })
        attendanceTableWidget,
    required DateTime lastAttendanceDate,
  }) {
    return BlocBuilder<DatePickerBloc, DatePickerState>(
      builder: (context, state) {
        final DateTime startDate = state.startDate ??
            lastAttendanceDate.subtract(const Duration(days: 7));
        final DateTime endDate = state.endDate ?? lastAttendanceDate;

        return StreamBuilder<List<AttendanceForGroupAndSubject>?>(
          stream: attendanceRepository.attendanceForGroupAndSubject(
            widget.groupId,
            widget.subjectId,
            startDate: format.format(startDate),
            endDate: format.format(endDate.add(const Duration(days: 1))),
          ),
          builder: (context, attendanceSnap) {
            if (attendanceSnap.connectionState == ConnectionState.waiting) {
              return Loading();
            }

            return attendanceTableWidget(
              attendanceSnap.data,
              startDate: startDate,
              endDate: endDate,
            );
          },
        );
      },
    );
  }

  Widget _getAttendanceTableWidget(
    List<Student> students,
    List<AttendanceForGroupAndSubject>? attendance, {
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: AttendanceTable(
          groupId: widget.groupId,
          subjectId: widget.subjectId,
          students: students,
          attendance: attendance,
          startDate: startDate,
          endDate: endDate,
        ),
      ),
    );
  }
}
