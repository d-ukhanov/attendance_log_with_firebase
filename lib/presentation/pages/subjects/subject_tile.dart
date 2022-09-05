// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:page_transition/page_transition.dart';

// Project imports:
import 'package:attendance_log_with_firebase/core/domain/models/subject.dart';
import 'package:attendance_log_with_firebase/presentation/pages/attendance/attendance.dart';

class SubjectTile extends StatelessWidget {
  final Subject subject;
  final String groupId;

  const SubjectTile({required this.subject, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        margin: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: _buildSubjectListTile(context),
      ),
    );
  }

  Widget _buildSubjectListTile(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
      title: Text(subject.name, textAlign: TextAlign.center),
      onTap: () => _toAttendancePage(context),
    );
  }

  void _toAttendancePage(BuildContext context) {
    Navigator.of(context).push(
      PageTransition(
        child: Attendance(
          groupId: groupId,
          subjectId: subject.uid,
          subjectName: subject.name,
        ),
        alignment: Alignment.bottomCenter,
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 500),
        reverseDuration: const Duration(milliseconds: 500),
        type: PageTransitionType.rightToLeft,
      ),
    );
  }
}
