import 'dart:async';

import 'package:attendance_log_with_firebase/models/student.dart';
import 'package:attendance_log_with_firebase/shared/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:attendance_log_with_firebase/services/database.dart';
import 'package:attendance_log_with_firebase/models/subject.dart';
import 'package:attendance_log_with_firebase/models/group.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:attendance_log_with_firebase/shared/restart_widget.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;

class AttendanceTable extends StatefulWidget {
  @override
  _AttendanceTable createState() => _AttendanceTable();
}

class _AttendanceTable extends State<AttendanceTable> {
  @override
  Widget build(BuildContext context) {
    final students = Provider.of<List<Student>>(context) ?? [];
    for (var student in students) {
      print(student.fio ?? 'Я тут');
    }
    
    var allColumnDateCount = [];
    var columnDateCount = [];
    var dateToRemove = [];

    final attendance =
        Provider.of<List<AttendanceForGroupAndSubject>>(context) ?? [];
    for (var attendancePerStudent in attendance) {
      allColumnDateCount.add(attendancePerStudent.date);
    }

    var now = new DateTime.now();
    initializeDateFormatting("ru");
    DateFormat format = DateFormat("y-MM-dd HH:mm");

    allColumnDateCount.sort((a, b) {
      return a.compareTo(b);
    });

    var endDate;
    var startDate;

    if(allColumnDateCount.isNotEmpty) {
      endDate = format.parse(allColumnDateCount.last ?? "").add(new Duration(days: 1)) ;
      startDate = endDate.subtract(new Duration(days: 7)) ;
    }


    allColumnDateCount.forEach((e) {
      var date = format.parse(e);
      if(date.isAfter(startDate)  && date.isBefore(endDate))
        columnDateCount.add(e);
    });
  //  print("datetoremove1" + dateToRemove.toString());
    //columnDateCount = allColumnDateCount.removeWhere((e) => dateToRemove.contains(e));
  //  print("datetolive1" + columnDateCount.toString());

    final dateController = StreamController<List<dynamic>>.broadcast();
    dateController.stream.listen((value) {
      columnDateCount.clear();
      allColumnDateCount.forEach((e) {
        var date = format.parse(e);
        print(value.first);
        print(value.last);
        print("date " + date.toString());
        if(date.isAfter(startDate) && date.isBefore(endDate)) {
          print("e " +  e);
          columnDateCount.add(e);
        }
      });
      print("datetoremove1" + dateToRemove.toString());
      print("datetolive1" + columnDateCount.toString());
    });

    final groupIdForAttendance = Provider.of<GroupIdForAttendance>(context);
    final subjectIdForAttendance = Provider.of<SubjectIdForAttendance>(context);


    Color currentDropMenuColor = Colors.green;

    String findStudentForDate(date, studentId) {
      var funcState = "";
      attendance.forEach((element) {
        if (element.date == date && element.attendanceMap.isNotEmpty) {
          element.attendanceMap.forEach((id, state) {
            if (id == studentId) {
              print(id + state);
              funcState = state;
            }
          });
        }
      });
      return funcState;
    }

    DropdownButtonFormField dropField(state, date, studentId) =>
        DropdownButtonFormField(
          value: state,
          items: [
            DropdownMenuItem<String>(
              value: "",
              child: Center(
                child: Container(
                    alignment: Alignment.center,
                    child: Text("", overflow: TextOverflow.ellipsis)),
              ),
            ),
            DropdownMenuItem<String>(
              value: "Присутствовал",
              child: Center(
                child: Text(
                  "П",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            DropdownMenuItem<String>(
              value: "Уважительная причина",
              child: Center(
                child: Text(
                  "У/П", overflow: TextOverflow.ellipsis,
                  //style: TextStyle(backgroundColor: Colors.yellow),
                ),
              ),
            ),
            DropdownMenuItem<String>(
              value: "Неуважительная причина",
              child: Center(
                child: Text(
                  "Н/П", overflow: TextOverflow.ellipsis,
                  //style: TextStyle(backgroundColor: Colors.red),
                ),
              ),
            ),
          ],
          onChanged: (val) {
            setState(() => state = val);
            if (val == "Присутствовал") {
              setState(() => currentDropMenuColor = Colors.green);
              DatabaseService().updateAttendanceForStudent(
                  date,
                  groupIdForAttendance.groupId,
                  subjectIdForAttendance.subjectId,
                  studentId: studentId,
                  state: val);
              print("1");
            }
            if (val == "Уважительная причина") {
              setState(() => currentDropMenuColor = Colors.yellow);
              DatabaseService().updateAttendanceForStudent(
                  date,
                  groupIdForAttendance.groupId,
                  subjectIdForAttendance.subjectId,
                  studentId: studentId,
                  state: val);
              print('2');
            }
            if (val == "Неуважительная причина") {
              setState(() => currentDropMenuColor = Colors.red);
              DatabaseService().updateAttendanceForStudent(
                  date,
                  groupIdForAttendance.groupId,
                  subjectIdForAttendance.subjectId,
                  studentId: studentId,
                  state: val);
              print('3 ' +
                  studentId +
                  " " +
                  val +
                  " " +
                  date +
                  groupIdForAttendance.groupId +
                  subjectIdForAttendance.subjectId);
            }
          },
          //dropdownColor:
          style: TextStyle(
            color: Colors.black,
            fontSize: 14.0,
          ),
          isExpanded: true,
          decoration: InputDecoration.collapsed(hintText: ''),
        );

    String _validateDate(String date) {
      RegExp regex = RegExp(
          r'((((19|20)([2468][048]|[13579][26]|0[48])|2000)-02-29|((19|20)[0-9]{2}-(0[4678]|1[02])-(0[1-9]|[12][0-9]|30)|(19|20)[0-9]{2}-(0[1359]|11)-(0[1-9]|[12][0-9]|3[01])|(19|20)[0-9]{2}-02-(0[1-9]|1[0-9]|2[0-8])))\s([01][0-9]|2[0-3]):([012345][0-9]))');
      if (date.isEmpty)
        return 'Пожалуйста, введите дату';
      else if (!regex.hasMatch(date))
        return "Неправильный формат даты. Пример: " +
            DateFormat("y-MM-dd HH:mm", "ru").format(now);
      else
        return null;
    }

    void _showDataAddPanel({date}) {
      final _formKey = GlobalKey<FormState>();
      var _inputDate = date ?? format.format(now);
      showModalBottomSheet(
          isScrollControlled: true,
          elevation: 5,
          context: context,
          builder: (context) => Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                          autofocus: true,
                          keyboardType: TextInputType.datetime,
                          initialValue: _inputDate,
                          validator: (val) => _validateDate(val),
                          decoration: textInputDecoration.copyWith(
                              labelText: 'Дата и время',
                              labelStyle: TextStyle(color: colorEnd)),
                          onChanged: (val) => setState(() => _inputDate = val)),
                      if (date != null)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: colorEnd,
                                      onPrimary: Colors.black),
                                  child: Text(
                                    'Обновить дату',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    if (_formKey.currentState.validate()) {
                                      setState(
                                          () => columnDateCount.remove(date));
                                      setState(() =>
                                          columnDateCount.add(_inputDate));
                                      DatabaseService()
                                          .updateAttendanceForStudent(
                                        date,
                                        groupIdForAttendance.groupId,
                                        subjectIdForAttendance.subjectId,
                                        changeDate: _inputDate,
                                      );
                                      Navigator.pop(context);
                                    }
                                  }),
                              SizedBox(
                                width: 20.0,
                              ),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: colorEnd,
                                      onPrimary: Colors.black),
                                  child: Text(
                                    'Удалить все записи',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    setState(
                                        () => columnDateCount.remove(date));
                                    DatabaseService()
                                        .deleteAttendanceForStudent(
                                      date,
                                      groupIdForAttendance.groupId,
                                      subjectIdForAttendance.subjectId,
                                    );
                                    Navigator.pop(context);
                                  }),
                            ],
                          ),
                        )
                      else
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: colorEnd, onPrimary: Colors.black),
                            child: Text(
                              'Добавить',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                if (date != null) {
                                  setState(() => columnDateCount.remove(date));
                                  setState(
                                      () => columnDateCount.add(_inputDate));
                                  DatabaseService().updateAttendanceForStudent(
                                    date,
                                    groupIdForAttendance.groupId,
                                    subjectIdForAttendance.subjectId,
                                    changeDate: _inputDate,
                                  );
                                } else {
                                  print(_inputDate);
                                  setState(
                                      () => columnDateCount.add(_inputDate));
                                  DatabaseService().updateAttendanceForStudent(
                                      _inputDate,
                                      groupIdForAttendance.groupId,
                                      subjectIdForAttendance.subjectId);
                                }
                                Navigator.pop(context);
                              }
                            })
                    ],
                  ),
                ),
              ));
    }

    return Column(
      children: [
        MaterialButton(
            color: colorBegin,
            onPressed: () async {
              final List<DateTime> picked =
                  await DateRangePicker.showDatePicker(
                context: context,
                locale: const Locale("ru", "RU"),
                initialFirstDate: startDate,
                initialLastDate:
                    endDate,
                firstDate: new DateTime(now.year - 5, now.month, now.day),
                lastDate: new DateTime(now.year + 5, now.month, now.day),
              );
              if (picked != null && picked.length == 2) {
                  startDate = picked.first;
                  endDate = picked.last.add(new Duration(days: 1));
                  dateController.add([startDate, endDate]);
                  print("startandenddate2" + startDate.toString() + endDate.toString());
                 /* columnDateCount.forEach((e) {
                    var date = format.parse(e);
                    if(date.isBefore(startDate) || date.isAfter(endDate))
                        dateToRemove.add(e);
                  });
                  print("datetoremove2" + dateToRemove.toString());
                  columnDateCount.removeWhere( (e) => dateToRemove.contains(e));
                  print("datetolive2 " +columnDateCount.toString());*/
                }
            },
            child: new Text(
              "Выберите диапазон дат",
              style: TextStyle(fontSize: 14.0, color: Colors.white),
            )),
        StreamBuilder<List<dynamic>>(
          stream: dateController.stream,
          builder: (context, snapshot) {
            print("snapshot" + snapshot.data.toString());
            return Expanded(
                  child: Container(
                    margin: EdgeInsets.all(10),
                    child: SingleChildScrollView(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(width: 1, color: colorBegin)),
                                alignment: Alignment.center,
                                width: 100.0,
                                height: 60.0,
                                child: Text('Students',
                                    style: TextStyle(
                                        fontSize: 16.0, fontWeight: FontWeight.w500)),
                              ),
                              // Text('Students',
                              //    textAlign: TextAlign.center,
                              //     style: TextStyle(fontWeight: FontWeight.bold)),
                              for (var student in students)
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(width: 1, color: colorBegin)),
                                  alignment: Alignment.center,
                                  width: 100.0,
                                  height: 50.0,
                                  child: Text(student.fio,
                                      style: TextStyle(fontSize: 12.0)),
                                ),
                              //Text(student.fio),
                            ],
                          ),
                          Flexible(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    for (int i = 0; i < columnDateCount.length; i++)
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                                width: 1, color: colorBegin)),
                                        alignment: Alignment.center,
                                        width: 100.0,
                                        height: 60.0,
                                        child: TextButton(
                                          child: Text(
                                            DateFormat("H:mm,\n EEE, d MMM\n y", "ru")
                                                .format(
                                                    format.parse(columnDateCount[i])),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Colors.black),
                                            maxLines: 3,
                                          ),
                                          onLongPress: () => _showDataAddPanel(
                                              date: columnDateCount[i]),
                                          onPressed: () {},
                                        ),
                                      ),
                                  ]),
                                  for (var student in students)
                                    Row(children: [
                                      for (var column in columnDateCount)
                                        Container(
                                          decoration: BoxDecoration(
                                            color: currentDropMenuColor,
                                            border:
                                                Border.all(width: 1, color: colorBegin),
                                          ),
                                          alignment: Alignment.center,
                                          width: 100.0,
                                          height: 50.0,
                                          child: dropField(
                                              findStudentForDate(
                                                  column, student.studentId),
                                              column,
                                              student.studentId),
                                        ),
                                      //dropAttendanceOfStudent(currentState),
                                    ])
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
            );
          }
        ),
        Container(
          margin: EdgeInsets.only(right: 5, bottom: 5),
          alignment: Alignment.bottomRight,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: colorBegin, onPrimary: Colors.black),
            child: Text(
              'Добавить занятие',
              style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
            onPressed: () => _showDataAddPanel(),
          ),
        ),
      ],
    );
    //print(monitorGroups);
  }
}

/*

 Expanded(
          child: Container(
            margin: EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildCells(20),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildRows(20),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),


          Container(
          margin: EdgeInsets.all(10),
          child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              border: TableBorder.all(width: 1, color: Colors.purple),
              columnWidths: {
                0: FractionColumnWidth(0.3)
              },
              children: [
                TableRow(children: [
                  Text('Students',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  for (int i = 0; i < columnDateCount.length; i++)
                    TextButton(
                      child: Text(
                        columnDateCount[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black),
                        maxLines: 3,
                      ),
                      onLongPress: () =>
                          _showDataAddPanel(date: columnDateCount[i]),
                      onPressed: () {},
                    ),
                ]),
                for (var student in students)
                  TableRow(children: [
                    Text(student.fio),
                    for (var column in columnDateCount)
                      dropField(findStudentForDate(column, student.studentId),
                          currentDropMenuColor, column, student.studentId),
                    //dropAttendanceOfStudent(currentState),
                  ])
              ]),
        ),

 DateFormat("H:mm,\n EEE, d MMM\n y",
              Localizations.localeOf(context).toString())
          .format(now),
      DateFormat("H:mm,\n EEE, d MMM\n y", "ru")
          .format(now.add(new Duration(days: 1))),
      DateFormat("H:mm,\n EEE, d MMM\n y", "ru")
          .format(now.add(new Duration(days: 2)))


students.forEach((student) {
      rows.add(TableRow(children: [
        Text(student.fio),
        for (var column in columnDateCount)
          dropField(currentDropMenuColor, column, student.studentId),
        //dropAttendanceOfStudent(currentState),
      ]));
    });


 StickyHeadersTable(
                columnsLength: columnDateCount.length,
                rowsLength: students.length,
                columnsTitleBuilder: (i) => TextFormField(
                    initialValue: columnDateCount[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    maxLines: 3,
                    onChanged: (val) {
                      setState(() => columnDateCount[i] = val);
                      print(columnDateCount[i]);
                    }),
                rowsTitleBuilder: (i) => Text(students[i].fio),
                contentCellBuilder: (i, j) => dropField(currentDropMenuColor,
                    columnDateCount[i], students[j].student_id),
                legendCell: Text('Students',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),

 */

/*
DataTable(
                showBottomBorder: true,
                horizontalMargin: 6.0,
                columnSpacing: 6.0,
                headingRowHeight: 32.0,
                dataRowHeight: 100.0,
                columns: <DataColumn>[
                  DataColumn(
                    label: Text('Students',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text(DateFormat.yMMMMEEEEd().format(now),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text(
                        DateFormat.yMMMMEEEEd()
                            .format(now.add(new Duration(days: 1))),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text(
                        DateFormat.yMMMMEEEEd()
                            .format(now.add(new Duration(days: 2))),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('Дата4',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('Дата5',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('Дата6',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
                rows: List.generate(
                  students.length,
                  (index) => _getDataRow(students[index]),
                )),

                 DataRow _getDataRow(student) {
      return DataRow(
        cells: <DataCell>[
          DataCell(Text(student.fio)),
          //dropAttendanceOfStudent(currentState),
          DataCell(dropField(currentDropMenuColor, now, student.student_id)),
          DataCell(dropField(currentDropMenuColor,
              now.add(new Duration(days: 1)), student.student_id)),
          DataCell(Text('болел')),
          DataCell(Text('Был')),
          DataCell(Text('Был')),
          DataCell(Text('Был')),
        ],
      );
    }

 */
