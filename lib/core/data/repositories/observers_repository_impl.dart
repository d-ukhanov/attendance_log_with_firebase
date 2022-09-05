// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'package:attendance_log_with_firebase/core/domain/repositories/observers_repository.dart';
import 'package:attendance_log_with_firebase/src/constants/constants_firebase.dart';

class ObserversRepositoryImpl implements ObserversRepository {
  final CollectionReference monitorsCollection = FirebaseFirestore.instance
      .collection(ConstantsFirebase.monitorsCollection);

  @override
  Stream<QuerySnapshot> observerFromUserUid(String uid) {
    final Query monitorQuery = monitorsCollection
        .where(ConstantsFirebase.monitorsFieldMonitorId, isEqualTo: uid);
    return monitorQuery.snapshots();
  }

  @override
  Stream<List<String>> getObserverGroupIds(String uid) {
    return observerFromUserUid(uid).map(_groupIdsFromSnapshot);
  }

  List<String> _groupIdsFromSnapshot(QuerySnapshot snapshot) {
    final List<String> groupIds = [];

    for (final element in snapshot.docs) {
      for (final id in element.get(ConstantsFirebase.monitorsFieldGroupsId)) {
        groupIds.add(id);
      }
    }

    return groupIds;
  }
}
