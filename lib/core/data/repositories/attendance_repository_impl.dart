// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'package:attendance_log_with_firebase/core/domain/repositories/attendance_repository.dart';
import 'package:attendance_log_with_firebase/core/domain/models/student.dart';
import 'package:attendance_log_with_firebase/src/constants/constants_firebase.dart';
import 'package:attendance_log_with_firebase/utils/logger.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final CollectionReference attendanceCollection = FirebaseFirestore.instance
      .collection(ConstantsFirebase.attendanceCollection);

  @override
  Stream<List<AttendanceForGroupAndSubject>> attendanceForGroupAndSubject(
    String groupId,
    String subjectId,
  ) {
    final attendanceForGroupAndSubject = attendanceCollection
        .where(ConstantsFirebase.attendanceFieldGroupId, isEqualTo: groupId)
        .where(
          ConstantsFirebase.attendanceFieldSubjectId,
          isEqualTo: subjectId,
        );

    return attendanceForGroupAndSubject
        .snapshots()
        .map(_attendanceFromSnapshot);
  }

  @override
  Future<void> updateAttendanceForStudent(
    String date,
    String groupId,
    String subjectId, {
    String? studentId,
    String? state,
    String? changeDate,
    List<String>? groupStudentIds,
  }) async {
    try {
      await attendanceCollection
          .where(ConstantsFirebase.attendanceFieldGroupId, isEqualTo: groupId)
          .where(
            ConstantsFirebase.attendanceFieldSubjectId,
            isEqualTo: subjectId,
          )
          .where(ConstantsFirebase.attendanceFieldDate, isEqualTo: date)
          .limit(1)
          .get()
          .then((event) {
        if (event.docs.isNotEmpty) {
          final String documentId =
              event.docs.first.id; //if it is a single document

          if (changeDate != null) {
            return attendanceCollection.doc(documentId).update({
              ConstantsFirebase.attendanceFieldDate: changeDate,
            });
          } else {
            return attendanceCollection.doc(documentId).update({
              '${ConstantsFirebase.attendanceFieldStudentId}.$studentId': state,
            });
          }
        } else {
          final Map<String, String> studentAttendance = {};
          groupStudentIds?.forEach((studentId) {
            studentAttendance[studentId] = 'Присутствовал';
          });

          return attendanceCollection.doc().set({
            ConstantsFirebase.attendanceFieldDate: date,
            ConstantsFirebase.attendanceFieldGroupId: groupId,
            ConstantsFirebase.attendanceFieldSubjectId: subjectId,
            ConstantsFirebase.attendanceFieldStudentId: studentAttendance,
          });
        }
      });
    } on Exception catch (e) {
      Log.logger.e(e);
    }
  }

  @override
  Future deleteAttendanceForStudent(
    String date,
    String groupId,
    String subjectId,
  ) async {
    try {
      await attendanceCollection
          .where(ConstantsFirebase.attendanceFieldGroupId, isEqualTo: groupId)
          .where(
            ConstantsFirebase.attendanceFieldSubjectId,
            isEqualTo: subjectId,
          )
          .where(ConstantsFirebase.attendanceFieldDate, isEqualTo: date)
          .limit(1)
          .get()
          .then((event) {
        if (event.docs.isNotEmpty) {
          final String documentId =
              event.docs.first.id; //if it is a single document

          return attendanceCollection.doc(documentId).delete();
        }
      });
    } on Exception catch (e) {
      Log.logger.e(e);
    }
  }

  List<AttendanceForGroupAndSubject> _attendanceFromSnapshot(
    QuerySnapshot snapshot,
  ) {
    return snapshot.docs.map((doc) {
      return AttendanceForGroupAndSubject(
        attendanceMap:
            doc.get(ConstantsFirebase.attendanceFieldStudentId) ?? {'': ''},
        date: doc.get(ConstantsFirebase.attendanceFieldDate) ?? '',
      );
    }).toList();
  }
}
