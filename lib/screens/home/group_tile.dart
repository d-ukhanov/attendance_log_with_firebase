import 'package:attendance_log_with_firebase/screens/subjects/subject.dart';
import 'package:flutter/material.dart';
import 'package:attendance_log_with_firebase/models/group.dart';
import 'package:attendance_log_with_firebase/shared/constants.dart';
import 'package:page_transition/page_transition.dart';

class GroupTile extends StatelessWidget {
  final Group group;

  GroupTile({this.group});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Container(
            height: 100,
            child: Card(
              margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
              child: Center(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      group.groupId,
                      style: TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                    //backgroundImage: AssetImage('assets/coffee_icon.png'),
                    radius: 20.0,
                    backgroundColor: colorEnd,
                  ),
                  title: Text(group.name),
                  onTap: () => Navigator.push(
                      context,
                      PageTransition(
                        child: Subjects(
                          groupId: group.groupId,
                          groupName: group.name,
                        ),
                        alignment: Alignment.bottomCenter,
                        curve: Curves.easeInOut,
                        duration: Duration(milliseconds: 500),
                        reverseDuration: Duration(milliseconds: 500),
                        type: PageTransitionType.rightToLeft,
                      )),
                ),
              ),
            )));
  }
}
