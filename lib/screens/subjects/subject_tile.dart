import 'package:attendance_log_with_firebase/screens/attendance/attendance.dart';
import 'package:flutter/material.dart';
import 'package:attendance_log_with_firebase/models/subject.dart';
import 'package:page_transition/page_transition.dart';

class SubjectTile extends StatelessWidget {
  final Subject subject;
  final String groupId;

  SubjectTile({this.subject, this.groupId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Container(
        height: 80,
        child: Card(
          margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
          child: Center(
            child: ListTile(
              title: Center(child: Text(subject.name.toString())),
              onTap: () => Navigator.push(
                  context,
                  PageTransition(
                    child: Attendance(
                      groupId: groupId,
                      subjectId: subject.uid,
                      subjectName: subject.name,
                    ),
                    alignment: Alignment.bottomCenter,
                    curve: Curves.easeInOut,
                    duration: Duration(milliseconds: 500),
                    reverseDuration: Duration(milliseconds: 500),
                    type: PageTransitionType.rightToLeft,
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
