// Flutter imports:
// Project imports:
import 'package:attendance_log_with_firebase/core/domain/models/student.dart';
import 'package:attendance_log_with_firebase/core/domain/repositories/attendance_repository.dart';
import 'package:attendance_log_with_firebase/src/constants/constants_ui.dart';
import 'package:flutter/material.dart';
// Package imports:
import 'package:intl/intl.dart';

class AddDateBottomSheet {
  final AttendanceRepository attendanceRepository;
  final DateFormat format;
  final DateTime now;
  final Function(String date) deleteDate;
  final Function(String date) addDate;
  final String groupId;
  final String subjectId;
  final List<Student> students;

  AddDateBottomSheet({
    required this.attendanceRepository,
    required this.format,
    required this.now,
    required this.deleteDate,
    required this.addDate,
    required this.groupId,
    required this.subjectId,
    required this.students,
  });

  void showAddDateBottomSheet(
    BuildContext context, {
    String? date,
  }) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController dateTextFieldController =
        TextEditingController(text: date ?? format.format(now));

    showModalBottomSheet(
      isScrollControlled: true,
      elevation: 5,
      constraints: const BoxConstraints(maxWidth: 400),
      context: context,
      builder: (context) => Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _getDateTextField(dateTextFieldController),
              const SizedBox(height: 8.0),
              if (date != null)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _getUpdateDateButton(
                        context,
                        date: date,
                        formKey: formKey,
                        dateTextFieldController: dateTextFieldController,
                      ),
                      const SizedBox(
                        width: 20.0,
                      ),
                      _getDeleteDateButton(context, date: date),
                    ],
                  ),
                )
              else
                _getAddDateButton(
                  context,
                  formKey: formKey,
                  dateTextFieldController: dateTextFieldController,
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _getDateTextField(TextEditingController dateTextFieldController) {
    return TextFormField(
      controller: dateTextFieldController,
      autofocus: true,
      keyboardType: TextInputType.datetime,
      validator: (val) => _validateDate(val, format: format, now: now),
      decoration: ConstantsUI.textInputDecoration.copyWith(
        labelText: 'Дата и время',
        labelStyle: const TextStyle(color: ConstantsUI.colorEnd),
      ),
      // onChanged: (val) => setState(() => _inputDate = val),
    );
  }

  Widget _getUpdateDateButton(
    BuildContext context, {
    required String date,
    required GlobalKey<FormState> formKey,
    required TextEditingController dateTextFieldController,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: ConstantsUI.colorEnd,
      ),
      child: const Text(
        'Обновить дату',
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () async {
        if (formKey.currentState?.validate() ?? false) {
          await attendanceRepository.updateAttendanceForStudent(
            date,
            groupId,
            subjectId,
            changeDate: dateTextFieldController.text,
          );

          deleteDate(date);
          addDate(dateTextFieldController.text);

          Navigator.pop(context);
        }
      },
    );
  }

  Widget _getDeleteDateButton(BuildContext context, {required String date}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: ConstantsUI.colorEnd,
      ),
      child: const Text(
        'Удалить все записи',
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () async {
        await attendanceRepository.deleteAttendanceForStudent(
          date,
          groupId,
          subjectId,
        );

        deleteDate(date);

        Navigator.pop(context);
      },
    );
  }

  Widget _getAddDateButton(
    BuildContext context, {
    required GlobalKey<FormState> formKey,
    required TextEditingController dateTextFieldController,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: ConstantsUI.colorEnd,
      ),
      child: const Text(
        'Добавить',
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () async {
        if (formKey.currentState?.validate() ?? false) {
          {
            await attendanceRepository.updateAttendanceForStudent(
              dateTextFieldController.text,
              groupId,
              subjectId,
              groupStudentIds:
                  students.map((student) => student.studentId).toList(),
            );

            addDate(dateTextFieldController.text);
          }
          Navigator.pop(context);
        }
      },
    );
  }

  String? _validateDate(
    String? date, {
    required DateFormat format,
    required DateTime now,
  }) {
    final RegExp regex = RegExp(
      r'((((19|20)([2468][048]|[13579][26]|0[48])|2000)-02-29|((19|20)[0-9]{2}-(0[4678]|1[02])-(0[1-9]|[12][0-9]|30)|(19|20)[0-9]{2}-(0[1359]|11)-(0[1-9]|[12][0-9]|3[01])|(19|20)[0-9]{2}-02-(0[1-9]|1[0-9]|2[0-8])))\s([01][0-9]|2[0-3]):([012345][0-9]))',
    );
    if (date == null || date.isEmpty) {
      return 'Пожалуйста, введите дату';
    } else if (!regex.hasMatch(date)) {
      return 'Неправильный формат даты. Пример: ${format.format(now)}';
    } else {
      return null;
    }
  }
}
