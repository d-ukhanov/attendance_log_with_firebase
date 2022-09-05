// Flutter imports:
// Project imports:
import 'package:attendance_log_with_firebase/core/domain/models/group.dart';
import 'package:attendance_log_with_firebase/presentation/pages/subjects/subject.dart';
import 'package:attendance_log_with_firebase/src/constants/constants_ui.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:page_transition/page_transition.dart';

class GroupTile extends StatelessWidget {
  final Group group;

  const GroupTile({required this.group});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        margin: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: _buildGroupListTile(context),
      ),
    );
  }

  Widget _buildGroupListTile(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 30, horizontal: 8),
      leading: _buildGroupAvatar(),
      title: Text(group.name),
      onTap: () => _toSubjectsPage(context),
    );
  }

  Widget _buildGroupAvatar() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: ConstantsUI.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: CircleAvatar(
        radius: 20.0,
        backgroundColor: Colors.transparent,
        child: Text(
          group.groupId,
          style: const TextStyle(color: Colors.white, fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _toSubjectsPage(BuildContext context) {
    Navigator.of(context).push(
      PageTransition(
        child: SubjectsPage(
          groupId: group.groupId,
          groupName: group.name,
        ),
        alignment: Alignment.bottomCenter,
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 300),
        reverseDuration: const Duration(milliseconds: 300),
        type: PageTransitionType.rightToLeft,
      ),
    );
  }
}
