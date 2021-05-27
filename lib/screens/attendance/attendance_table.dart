import 'dart:async';
import 'package:attendance_log_with_firebase/models/student.dart';
import 'package:attendance_log_with_firebase/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:attendance_log_with_firebase/services/database.dart';
import 'package:attendance_log_with_firebase/models/subject.dart';
import 'package:attendance_log_with_firebase/models/group.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;

class AttendanceTable extends StatefulWidget {
  @override
  _AttendanceTable createState() => _AttendanceTable();
}

class _AttendanceTable extends State<AttendanceTable> {
  @override
  Widget build(BuildContext context) {

    var now = new DateTime.now();
    initializeDateFormatting("ru");
    DateFormat format = DateFormat("y-MM-dd HH:mm");

    //Get the list of students from the stream and sort them alphabetically
    final students = Provider.of<List<Student>>(context) ?? [];
    students.sort((a, b) {
      return a.fio
          .toString()
          .toLowerCase()
          .compareTo(b.fio.toString().toLowerCase());
    });

    //Get data on student attendance from the stream
    final attendance =
        Provider.of<List<AttendanceForGroupAndSubject>>(context) ?? [];

    var allColumnDateCount = [];
    for (var attendancePerStudent in attendance) {
      allColumnDateCount.add(attendancePerStudent.date);
    }

    allColumnDateCount.sort((a, b) {
      return a.compareTo(b);
    });

    var endDate;
    var startDate;

    if (allColumnDateCount.isNotEmpty) {
      endDate = format
          .parse(allColumnDateCount.last ?? "")
          .add(new Duration(days: 1));
      startDate = endDate.subtract(new Duration(days: 7));
    }

    var columnDateCount = [];

    allColumnDateCount.forEach((e) {
      var date = format.parse(e);
      if (date.isAfter(startDate) && date.isBefore(endDate))
        columnDateCount.add(e);
    });

    //Track changes in the selected date range and update the date array
    final dateController = StreamController<List<dynamic>>.broadcast();
    dateController.stream.listen((value) {
      columnDateCount.clear();
      allColumnDateCount.forEach((e) {
        var date = format.parse(e);
        if (date.isAfter(startDate) && date.isBefore(endDate)) {
          columnDateCount.add(e);
        }
      });
    });

    final groupIdForAttendance = Provider.of<GroupIdForAttendance>(context);
    final subjectIdForAttendance = Provider.of<SubjectIdForAttendance>(context);

    Color currentDropMenuColor = Colors.green;

    DonutPieChart _findStudentStates(studentId, funcStartDate, funcEndDate) {
      int state1;
      int state2;
      int state3;
      attendance.forEach((element) {
        var date = format.parse(element.date);
        if (date.isAfter(funcStartDate) && date.isBefore(funcEndDate))
          element.attendanceMap.forEach((id, state) {
            if (id == studentId) {
              if (state == "Присутствовал") state1 += 1;
              if (state == "Уважительная причина") state2 += 1;
              if (state == "Неуважительная причина") state3 += 1;
            }
          });
      });
      final data = [
        new StudentStates(
            "Присутствовал", state1, charts.Color(r: 0, g: 204, b: 0)),
        new StudentStates("Уважительная причина", state2,
            charts.Color(r: 255, g: 153, b: 51)),
        new StudentStates(
            "Неуважительная причина", state3, charts.Color(r: 255, g: 0, b: 0)),
      ];
      return DonutPieChart.withSampleData(data);
    }

    //Function for finding student attendance data for a particular lesson
    String _findStateStudent(date, studentId) {
      var funcState = "";
      attendance.forEach((element) {
        if (element.date == date && element.attendanceMap.isNotEmpty) {
          element.attendanceMap.forEach((id, state) {
            if (id == studentId) {
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
                ),
              ),
            ),
            DropdownMenuItem<String>(
              value: "Неуважительная причина",
              child: Center(
                child: Text(
                  "Н/П", overflow: TextOverflow.ellipsis,
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
            }
            if (val == "Уважительная причина") {
              setState(() => currentDropMenuColor = Colors.yellow);
              DatabaseService().updateAttendanceForStudent(
                  date,
                  groupIdForAttendance.groupId,
                  subjectIdForAttendance.subjectId,
                  studentId: studentId,
                  state: val);
            }
            if (val == "Неуважительная причина") {
              setState(() => currentDropMenuColor = Colors.red);
              DatabaseService().updateAttendanceForStudent(
                  date,
                  groupIdForAttendance.groupId,
                  subjectIdForAttendance.subjectId,
                  studentId: studentId,
                  state: val);
            }
          },
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
                                {
                                  setState(
                                      () => columnDateCount.add(_inputDate));
                                  DatabaseService().updateAttendanceForStudent(
                                    _inputDate,
                                    groupIdForAttendance.groupId,
                                    subjectIdForAttendance.subjectId,
                                  );
                                }
                                Navigator.pop(context);
                              }
                            })
                    ],
                  ),
                ),
              ));
    }

    //Function for displaying information about the attendance of a particular student in the form of a graph
    void _showStudentAttendance(String fio, String id) {
      showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: Text(
                  fio +
                      "\n(" +
                      format.format(startDate) +
                      " - " +
                      format.format(endDate) +
                      ")",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.black)),
              children: <Widget>[
                SizedBox(
                    width: 200.0,
                    height: 300.0,
                    child: _findStudentStates(id, startDate, endDate)),
              ],
            );
          });
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
                initialLastDate: endDate,
                firstDate: new DateTime(now.year - 5, now.month, now.day),
                lastDate: new DateTime(now.year + 5, now.month, now.day),
              );
              if (picked != null && picked.length == 2) {
                startDate = picked.first;
                endDate = picked.last.add(new Duration(days: 1));
                dateController.add([startDate, endDate]);
                dateController.close();
              }
            },
            child: new Text(
              "Выберите диапазон дат",
              style: TextStyle(fontSize: 14.0, color: Colors.white),
            )),
        StreamBuilder<List<dynamic>>(
            stream: dateController.stream,
            builder: (context, snapshot) {
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
                                  border:
                                      Border.all(width: 1, color: colorBegin)),
                              alignment: Alignment.center,
                              width: 100.0,
                              height: 60.0,
                              child: Text('Студенты',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500)),
                            ),
                            for (var student in students)
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        width: 1, color: colorBegin)),
                                alignment: Alignment.center,
                                width: 100.0,
                                height: 50.0,
                                child: TextButton(
                                  child: Text(student.fio,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.black)),
                                  onPressed: () => _showStudentAttendance(
                                      student.fio, student.studentId),
                                ),
                              ),
                          ],
                        ),
                        Flexible(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  for (int i = 0;
                                      i < columnDateCount.length;
                                      i++)
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
                                          DateFormat("H:mm,\n EEE, d MMM\n y",
                                                  "ru")
                                              .format(format
                                                  .parse(columnDateCount[i])),
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
                                          border: Border.all(
                                              width: 1, color: colorBegin),
                                        ),
                                        alignment: Alignment.center,
                                        width: 100.0,
                                        height: 50.0,
                                        child: dropField(
                                            _findStateStudent(
                                                column, student.studentId),
                                            column,
                                            student.studentId),
                                      ),
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
            }),
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
  }
}

class DonutPieChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  DonutPieChart(this.seriesList, {this.animate});

  factory DonutPieChart.withSampleData(dataOfStudent) {
    return new DonutPieChart(
      _createSampleData(dataOfStudent),
      animate: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.PieChart(
      seriesList,
      animate: animate,
      defaultRenderer: new charts.ArcRendererConfig(
        arcWidth: 15,
        arcRendererDecorators: [
          new charts.ArcLabelDecorator(
            showLeaderLines: false,
            outsideLabelStyleSpec: new charts.TextStyleSpec(fontSize: 18),
            labelPosition: charts.ArcLabelPosition.outside,
          )
        ],
      ),
      behaviors: [
        new charts.DatumLegend(
          position: charts.BehaviorPosition.bottom,
          outsideJustification: charts.OutsideJustification.middleDrawArea,
          horizontalFirst: false,
          cellPadding: new EdgeInsets.only(right: 4.0, bottom: 10.0),
          showMeasures: true,
          desiredMaxColumns: 1,
          desiredMaxRows: 3,
          legendDefaultMeasure: charts.LegendDefaultMeasure.firstValue,
          measureFormatter: (num value) {
            return value == null ? '-' : "$value";
          },
          entryTextStyle: charts.TextStyleSpec(
              color: charts.MaterialPalette.black,
              fontFamily: 'Roboto',
              fontSize: 16),
        ),
      ],
    );
  }

  static List<charts.Series<StudentStates, dynamic>> _createSampleData(
      dataOfStudent) {
    final List<StudentStates> data = [];
    data.addAll(dataOfStudent);
    return [
      new charts.Series<StudentStates, dynamic>(
        id: 'States',
        domainFn: (StudentStates state, _) => state.typeState,
        measureFn: (StudentStates state, _) => state.countStates,
        colorFn: (StudentStates state, _) => state.color,
        labelAccessorFn: (StudentStates state, _) => '${state.countStates}',
        data: data,
      )
    ];
  }
}
