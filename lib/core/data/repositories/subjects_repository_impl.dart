// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'package:attendance_log_with_firebase/core/domain/repositories/subjects_repository.dart';
import 'package:attendance_log_with_firebase/core/domain/models/subject.dart';
import 'package:attendance_log_with_firebase/src/constants/constants_firebase.dart';

class SubjectsRepositoryImpl implements SubjectsRepository {
  final CollectionReference subjectsCollection = FirebaseFirestore.instance
      .collection(ConstantsFirebase.subjectsCollection);

  @override
  Stream<List<Subject>> subjectsForGroup(String groupId) {
    final Query subjectsQuery = subjectsCollection.where(
      ConstantsFirebase.subjectsFieldGroupsId,
      arrayContainsAny: [groupId],
    );
    return subjectsQuery.snapshots().map(_subjectListFromSnapshot);
  }

  List<Subject> _subjectListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Subject(
        name: doc.get(ConstantsFirebase.subjectsFieldSubjectName).toString(),
        uid: doc.get(ConstantsFirebase.subjectsFieldSubjectId).toString(),
      );
    }).toList();
  }
}
