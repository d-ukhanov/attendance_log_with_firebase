// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:attendance_log_with_firebase/core/domain/models/subject.dart';
import 'package:attendance_log_with_firebase/presentation/pages/subjects/subject_tile.dart';

class SubjectList extends StatelessWidget {
  final List<Subject>? subjects;
  final String groupId;

  const SubjectList({super.key, required this.subjects, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final subjectsList = subjects;

    if (subjectsList != null) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView.separated(
            itemCount: subjectsList.length,
            itemBuilder: (_, index) =>
                SubjectTile(subject: subjectsList[index], groupId: groupId),
            separatorBuilder: (_, __) => const Divider(),
          ),
        ),
      );
    }

    return const SizedBox();
  }
}
