// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Package imports:
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:attendance_log_with_firebase/core/domain/models/student.dart';
import 'package:attendance_log_with_firebase/core/domain/repositories/attendance_repository.dart';
import 'package:attendance_log_with_firebase/presentation/pages/attendance/bloc/date_picker_bloc.dart';
import 'package:attendance_log_with_firebase/presentation/pages/attendance/dialogs/add_date_bottom_sheet.dart';
import 'package:attendance_log_with_firebase/presentation/pages/attendance/dialogs/student_attendance_dialog.dart';
import 'package:attendance_log_with_firebase/src/constants/constants_ui.dart';

class AttendanceTable extends StatefulWidget {
  final String groupId;
  final String subjectId;
  final List<Student> students;
  final List<AttendanceForGroupAndSubject>? attendance;
  final DateTime startDate;
  final DateTime endDate;

  const AttendanceTable({
    required this.groupId,
    required this.subjectId,
    required this.students,
    required this.attendance,
    required this.startDate,
    required this.endDate,
  });

  @override
  _AttendanceTableState createState() => _AttendanceTableState();
}

class _AttendanceTableState extends State<AttendanceTable> {
  final AttendanceRepository attendanceRepository = GetIt.I.get();

  late final DateTime now;
  late final DateFormat format;
  late final List<Student> students;

  late final AddDateBottomSheet addDateBottomSheetClass;
  final List<String> columnDateCount = [];

  @override
  void initState() {
    super.initState();

    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 4.0),
        _buildDatePickerButton(context),
        _buildTableWidget(context),
        _buildAddLessonButton(context),
        const SizedBox(height: 4.0),
      ],
    );
  }

  Widget _buildDatePickerButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style:
            ElevatedButton.styleFrom(backgroundColor: ConstantsUI.colorBegin),
        onPressed: () async {
          final DateTimeRange? picked = await showDateRangePicker(
            context: context,
            locale: const Locale('ru', 'RU'),
            initialDateRange:
                DateTimeRange(start: widget.startDate, end: widget.endDate),
            firstDate: DateTime(now.year - 5, now.month, now.day),
            lastDate: DateTime(now.year + 5, now.month, now.day),
          );
          if (picked != null && mounted) {
            context.read<DatePickerBloc>().add(
                  ChangeDateEvent(startDate: picked.start, endDate: picked.end),
                );
          }
        },
        child: const Text(
          'Выберите диапазон дат',
          style: TextStyle(fontSize: 14.0, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTableWidget(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _getStudentsColumn(),
              _getAttendanceColumn(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getStudentsColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: ConstantsUI.colorBegin),
          ),
          alignment: Alignment.center,
          width: 100.0,
          height: 60.0,
          child: const Text(
            'Студенты',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        for (var student in students)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: ConstantsUI.colorBegin,
              ),
            ),
            alignment: Alignment.center,
            width: 100.0,
            height: 50.0,
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: ConstantsUI.colorBackground,
              ),
              child: Text(
                student.fio,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              onPressed: () => _showStudentAttendanceDialog(
                student.fio,
                student.studentId,
              ),
            ),
          ),
      ],
    );
  }

  Widget _getAttendanceColumn(BuildContext context) {
    return Flexible(
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _getDateRow(context),
              for (var student in students)
                _getStudentAttendanceRow(context, student.studentId),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getStudentAttendanceRow(BuildContext context, String studentId) {
    return Row(
      children: [
        for (var column in columnDateCount)
          StatefulBuilder(
            builder: (context, cellState) {
              final String stateStudent = _findStateStudent(column, studentId);
              Color currentDropMenuColor = _getCellColor(stateStudent);
              void cellColorState(String stateStudent) => cellState(
                    () => currentDropMenuColor = _getCellColor(stateStudent),
                  );

              return Container(
                decoration: BoxDecoration(
                  color: currentDropMenuColor,
                  border: Border.all(
                    color: ConstantsUI.colorBegin,
                  ),
                ),
                alignment: Alignment.center,
                width: 100.0,
                height: 50.0,
                child: _getDropFieldWidget(
                  state: stateStudent,
                  date: column,
                  studentId: studentId,
                  cellColorState: cellColorState,
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _getDateRow(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < columnDateCount.length; i++)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: ConstantsUI.colorBegin,
              ),
            ),
            alignment: Alignment.center,
            width: 100.0,
            height: 60.0,
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: ConstantsUI.colorBackground,
              ),
              child: Text(
                DateFormat(
                  'H:mm,\n EEE, d MMM\n y',
                  'ru',
                ).format(
                  format.parse(columnDateCount[i]),
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.black,
                ),
                maxLines: 3,
              ),
              onPressed: () => addDateBottomSheetClass.showAddDateBottomSheet(
                context,
                date: columnDateCount[i],
              ),
            ),
          ),
      ],
    );
  }

  DropdownButtonFormField _getDropFieldWidget({
    required String state,
    required String date,
    required String studentId,
    required void Function(String stateStudent) cellColorState,
  }) {
    return DropdownButtonFormField(
      value: state,
      items: const [
        DropdownMenuItem<String>(
          value: 'Присутствовал',
          child: Center(
            child: Text(
              'П',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DropdownMenuItem<String>(
          value: 'Уважительная причина',
          child: Center(
            child: Text(
              'У/П',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DropdownMenuItem<String>(
          value: 'Неуважительная причина',
          child: Center(
            child: Text(
              'Н/П',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
      onChanged: (val) {
        cellColorState(val);

        attendanceRepository.updateAttendanceForStudent(
          date,
          widget.groupId,
          widget.subjectId,
          studentId: studentId,
          state: val,
        );
      },
      style: const TextStyle(
        color: Colors.black,
        fontSize: 14.0,
      ),
      isExpanded: true,
      decoration: const InputDecoration.collapsed(hintText: null),
    );
  }

  Widget _buildAddLessonButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: ConstantsUI.colorBegin,
        ),
        child: const Text(
          'Добавить занятие',
          style: TextStyle(fontSize: 16.0, color: Colors.white),
        ),
        onPressed: () =>
            addDateBottomSheetClass.showAddDateBottomSheet(context),
      ),
    );
  }

  void _init() {
    now = DateTime.now();
    initializeDateFormatting('ru');
    format = DateFormat('y-MM-dd hh:mm');

    //Get the list of students from the stream and sort them alphabetically
    students = widget.students;
    students.sort((a, b) {
      return a.fio.toLowerCase().compareTo(b.fio.toLowerCase());
    });

    //Get lesson date on student attendance
    if (widget.attendance != null && (widget.attendance?.isNotEmpty ?? false)) {
      for (final attendancePerStudent in widget.attendance!) {
        columnDateCount.add(attendancePerStudent.date);
      }

      columnDateCount.sort((a, b) {
        return a.compareTo(b);
      });
    }

    addDateBottomSheetClass = AddDateBottomSheet(
      attendanceRepository: attendanceRepository,
      format: format,
      now: now,
      deleteDate: (date) => setState(
        () => columnDateCount.remove(date),
      ),
      addDate: (date) {
        {
          final newDate = format.parse(date);
          final lastDate = format.parse(columnDateCount.last);
          if(newDate.isAfter(lastDate)) {
            context.read<DatePickerBloc>().add(
              ChangeDateEvent(endDate: format.parse(date)),
            );
          } else {
            columnDateCount.add(date);
            columnDateCount.sort((a, b) {
              return a.compareTo(b);
            });
          }
        }
      },
      groupId: widget.groupId,
      subjectId: widget.subjectId,
      students: students,
    );
  }

  //Function for finding student attendance data for a particular lesson
  String _findStateStudent(date, studentId) {
    String studentState = 'Присутствовал';

    if (widget.attendance != null) {
      for (final element in widget.attendance!) {
        if (element.date == date && element.attendanceMap.isNotEmpty) {
          element.attendanceMap.forEach((id, state) {
            if (id == studentId) {
              studentState = state;
            }
          });
        }
      }
    }
    return studentState;
  }

  Color _getCellColor(String studentState) {
    switch (studentState) {
      case 'Присутствовал':
        return Colors.green;
      case 'Уважительная причина':
        return Colors.yellow;
      case 'Неуважительная причина':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

//Function for displaying information about the attendance of a particular student in the form of a graph
  void _showStudentAttendanceDialog(String fio, String id) {
    showDialog(
      context: context,
      builder: (context) => StudentAttendanceDialog(
        fio: fio,
        id: id,
        format: format,
        endDate: widget.endDate,
        startDate: widget.startDate,
        attendance: widget.attendance,
      ),
    );
  }
}
