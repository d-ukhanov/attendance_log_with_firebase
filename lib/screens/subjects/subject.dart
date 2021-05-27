import 'package:attendance_log_with_firebase/models/subject.dart';
import 'package:attendance_log_with_firebase/screens/subjects/subject_list.dart';
import 'package:attendance_log_with_firebase/services/auth.dart';
import 'package:attendance_log_with_firebase/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:attendance_log_with_firebase/services/database.dart';
import 'package:provider/provider.dart';
import 'package:attendance_log_with_firebase/shared/restart_widget.dart';
import 'package:attendance_log_with_firebase/shared/constants.dart';
import 'package:flutter/animation.dart';

class Subjects extends StatefulWidget {
  final String groupId;
  final String groupName;

  const Subjects({Key key, this.groupId, this.groupName}) : super(key: key);

  @override
  _SubjectsState createState() => _SubjectsState(groupId, groupName);
}

class _SubjectsState extends State<Subjects> with TickerProviderStateMixin {
  final String groupId;
  final String groupName;

  _SubjectsState(this.groupId, this.groupName);

  final AuthService _auth = AuthService();

  AnimationController _controller;
  Animation<Color> _color;

  bool loading = false;

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
    return Provider<String>.value(
      value: groupId,
      child: StreamProvider<List<Subject>>.value(
        value: DatabaseService(groupId: groupId).subjects,
        initialData: null,
        child: Scaffold(
          backgroundColor: colorBackground,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: AnimatedBuilder(
              animation: _color,
              builder: (BuildContext context, Widget child) {
                return AppBar(
                    title: Text(groupName.toString() ?? ''),
                    backgroundColor: _color.value,
                    elevation: 0.0,
                    actions: [
                      TextButton.icon(
                        icon: Icon(Icons.person, color: colorBackground),
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
          body: loading
            ? Loading()
              : SubjectList(),
        ),
      ),
    );
  }
}
