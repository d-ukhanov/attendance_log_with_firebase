import 'package:attendance_log_with_firebase/models/subject.dart';
import 'package:attendance_log_with_firebase/screens/subjects/subject_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendance_log_with_firebase/models/group.dart';
import 'package:attendance_log_with_firebase/screens/home/group_tile.dart';

class SubjectList extends StatefulWidget {
  @override
  _SubjectListState createState() => _SubjectListState();
}

class _SubjectListState extends State<SubjectList> {
  @override
  Widget build(BuildContext context) {
    final subjects = Provider.of<List<Subject>>(context) ?? [];
    final groupId = Provider.of<String>(context);

    //print(monitorGroups);
    return ListView.separated(
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        return SubjectTile(
          subject: subjects[index],
          groupId: groupId,
        );
      },
      separatorBuilder: (BuildContext context, int index) => Divider(),
    );
  }
}
