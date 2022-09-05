// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'package:attendance_log_with_firebase/src/constants/constants_firebase.dart';
import 'package:attendance_log_with_firebase/core/domain/models/student.dart';
import 'package:attendance_log_with_firebase/core/domain/repositories/students_repository.dart';

class StudentsRepositoryImpl implements StudentsRepository {
  final CollectionReference studentsCollection =
  FirebaseFirestore.instance.collection(ConstantsFirebase.studentsCollection);

  @override
  Stream<List<Student>> studentsForGroup(String groupId) {
    final Query subjectsQuery = studentsCollection
        .where(ConstantsFirebase.studentsFieldGroupId, whereIn: [groupId]);
    return subjectsQuery.snapshots().map(_studentListFromSnapshot);
  }

  List<Student> _studentListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Student(
        fio: doc.get(ConstantsFirebase.studentsFieldFIO).toString(),
        studentId: doc.get(ConstantsFirebase.studentsFieldStudentId).toString(),
      );
    }).toList();
  }
}
