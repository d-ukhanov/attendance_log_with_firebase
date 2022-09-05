// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'package:attendance_log_with_firebase/core/domain/repositories/groups_repository.dart';
import 'package:attendance_log_with_firebase/core/domain/models/group.dart';
import 'package:attendance_log_with_firebase/src/constants/constants_firebase.dart';

class GroupsRepositoryImpl implements GroupsRepository {
  final CollectionReference groupsCollection =
      FirebaseFirestore.instance.collection(ConstantsFirebase.groupsCollection);

  @override
  Stream<List<Group>> groupsByIds(List<String> groupIds) {
    final Query groupsQuery = groupsCollection.where(
      ConstantsFirebase.groupsFieldGroupId,
      whereIn: groupIds,
    );

    return groupsQuery.snapshots().map(_groupListFromSnapshot);
  }

  List<Group> _groupListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Group(
        name: doc.get(ConstantsFirebase.groupsFieldGroupName).toString(),
        groupId: doc.get(ConstantsFirebase.groupsFieldGroupId).toString(),
      );
    }).toList();
  }
}
