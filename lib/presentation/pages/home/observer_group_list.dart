// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:attendance_log_with_firebase/core/domain/models/group.dart';
import 'package:attendance_log_with_firebase/presentation/pages/home/group_tile.dart';

class ObserverGroupsList extends StatelessWidget {
  final List<Group>? groups;

  const ObserverGroupsList(this.groups);

  @override
  Widget build(BuildContext context) {
    final observerGroups = groups;

    if (observerGroups != null) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView.separated(
            itemCount: observerGroups.length,
            itemBuilder: (_, index) => GroupTile(group: observerGroups[index]),
            separatorBuilder: (_, __) => const Divider(),
          ),
        ),
      );
    }

    return const SizedBox();
  }
}
