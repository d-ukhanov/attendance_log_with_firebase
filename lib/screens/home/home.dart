import 'package:attendance_log_with_firebase/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:attendance_log_with_firebase/services/database.dart';
import 'package:provider/provider.dart';
import 'package:attendance_log_with_firebase/screens/home/monitor_group_list.dart';
import 'package:attendance_log_with_firebase/models/group.dart';
import 'package:attendance_log_with_firebase/models/user.dart';
import 'package:attendance_log_with_firebase/shared/restart_widget.dart';
import 'package:attendance_log_with_firebase/shared/constants.dart';
import 'package:flutter/animation.dart';

class Home extends StatefulWidget {
  final String userId;

  const Home({Key key, this.userId}) : super(key: key);

  @override
  _HomeState createState() => _HomeState(userId);
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  final AuthService _auth = AuthService();
  final String userId;

  _HomeState(this.userId);

  AnimationController _controller;
  Animation<Color> _color;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 3),
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
    return StreamProvider<List<Group>>.value(
      value: DatabaseService(uid: userId).monitors,
      initialData: null,
      child: Scaffold(
            backgroundColor: colorBackground,
            appBar:  PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: AnimatedBuilder(
                animation: _color,
                builder: (BuildContext context, Widget child) {
                  return AppBar(
                      title: Text('Журнал посещаемости'),
                      backgroundColor: _color.value,
                      elevation: 0.0,
                      actions: [
                        TextButton.icon(
                          icon: Icon(Icons.person, color: colorBackground),
                          label: Text(
                            'logout',
                            style: TextStyle(color: Colors.black),
                          ),
                          onPressed: () async {
                            await _auth.signOut();
                          },
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        TextButton.icon(
                          icon: Icon(Icons.autorenew, color: colorBackground),
                          label: Text(
                            'restart',
                            style: TextStyle(color: Colors.black),
                          ),
                          onPressed: () => RestartWidget.restartApp(context),
                        ),
                      ]);
                },
              ),
            ),
            body: MonitorGroupList(),
          ),
      );
  }
}
