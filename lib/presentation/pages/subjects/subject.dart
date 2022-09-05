// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get_it/get_it.dart';

// Project imports:
import 'package:attendance_log_with_firebase/core/domain/repositories/subjects_repository.dart';
import 'package:attendance_log_with_firebase/core/domain/models/subject.dart';
import 'package:attendance_log_with_firebase/presentation/pages/subjects/subject_list.dart';
import 'package:attendance_log_with_firebase/presentation/widgets/loading.dart';
import 'package:attendance_log_with_firebase/presentation/widgets/custom_scaffold.dart';

class SubjectsPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const SubjectsPage({super.key, required this.groupId, required this.groupName});

  @override
  _SubjectsPageState createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  late final SubjectsRepository subjectsRepository;

  @override
  void initState() {
    super.initState();

    subjectsRepository = GetIt.I.get();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: widget.groupName,
      body: StreamBuilder<List<Subject>>(
        stream: subjectsRepository.subjectsForGroup(widget.groupId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loading();
          }

          if (snapshot.hasData && (snapshot.data?.isNotEmpty ?? false)) {
            return SubjectList(
              subjects: snapshot.data,
              groupId: widget.groupId,
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
