import 'package:attendance_log_with_firebase/models/student.dart';
import 'package:attendance_log_with_firebase/models/subject.dart';
import 'package:attendance_log_with_firebase/screens/attendance/attendance_table.dart';
import 'package:attendance_log_with_firebase/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:attendance_log_with_firebase/services/database.dart';
import 'package:provider/provider.dart';
import 'package:attendance_log_with_firebase/models/group.dart';
import 'package:attendance_log_with_firebase/shared/restart_widget.dart';
import 'package:attendance_log_with_firebase/shared/constants.dart';
import 'package:flutter/animation.dart';

class Attendance extends StatefulWidget {
  final String groupId;
  final String subjectId;
  final String subjectName;

  const Attendance({Key key, this.groupId, this.subjectId, this.subjectName})
      : super(key: key);

  @override
  _AttendanceState createState() =>
      _AttendanceState(groupId, subjectId, subjectName);
}

class _AttendanceState extends State<Attendance> with TickerProviderStateMixin {
  final String groupId;
  final String subjectId;
  final String subjectName;

  _AttendanceState(this.groupId, this.subjectId, this.subjectName);

  final AuthService _auth = AuthService();

  AnimationController _controller;
  Animation<Color> _color;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _color = colorAppBarTween.animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          Provider<GroupIdForAttendance>.value(
              value: GroupIdForAttendance(groupId: groupId)),
          Provider<SubjectIdForAttendance>.value(
              value: SubjectIdForAttendance(subjectId: subjectId)),
          StreamProvider<List<Student>>.value(
              value: DatabaseService(groupId: groupId).students,
              initialData: null),
          StreamProvider<List<AttendanceForGroupAndSubject>>.value(
              value: DatabaseService(groupId: groupId, subjectId: subjectId)
                  .attendance,
              initialData: null)
        ],
        child: Scaffold(
          backgroundColor: colorBackground,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: AnimatedBuilder(
              animation: _color,
              builder: (BuildContext context, Widget child) {
                return AppBar(
                    title: Text(subjectName ?? ''),
                    backgroundColor: _color.value,
                    elevation: 0.0,
                    actions: [
                      TextButton.icon(
                        icon: Icon(
                          Icons.person,
                          color: colorBackground,
                        ),
                        label: Text(
                          'выйти',
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: () async {
                          await _auth.signOut();
                          RestartWidget.restartApp(context);
                        },
                      ),
                    ]);
              },
            ),
          ),
          body: AttendanceTable(),
        ));
  }
}
