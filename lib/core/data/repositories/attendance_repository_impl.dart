// Package imports:
import 'package:attendance_log_with_firebase/core/domain/models/student.dart';
// Project imports:
import 'package:attendance_log_with_firebase/core/domain/repositories/attendance_repository.dart';
import 'package:attendance_log_with_firebase/src/constants/constants_firebase.dart';
import 'package:attendance_log_with_firebase/utils/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final CollectionReference attendanceCollection = FirebaseFirestore.instance
      .collection(ConstantsFirebase.attendanceCollection);

  @override
  Stream<List<AttendanceForGroupAndSubject>> attendanceForGroupAndSubject(
    String groupId,
    String subjectId, {
    required String startDate,
    required String endDate,
  }) {
    final attendanceForGroupAndSubject = attendanceCollection
        .where(ConstantsFirebase.attendanceFieldGroupId, isEqualTo: groupId)
        .where(
          ConstantsFirebase.attendanceFieldSubjectId,
          isEqualTo: subjectId,
        )
        .where(
          ConstantsFirebase.attendanceFieldDate,
          isGreaterThanOrEqualTo: startDate,
        )
        .where(
          ConstantsFirebase.attendanceFieldDate,
          isLessThanOrEqualTo: endDate,
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
              '${ConstantsFirebase.attendanceFieldStudentsAttendance}.$studentId':
                  state,
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
            ConstantsFirebase.attendanceFieldStudentsAttendance:
                studentAttendance,
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

  @override
  Future<String> getLastEntryDate() async {
    final lastSnap = await attendanceCollection
        .orderBy(ConstantsFirebase.attendanceFieldDate)
        .snapshots()
        .first;
    final String lastEntryDate =
        lastSnap.docs.last.get(ConstantsFirebase.attendanceFieldDate);

    return lastEntryDate;
  }

  List<AttendanceForGroupAndSubject> _attendanceFromSnapshot(
    QuerySnapshot snapshot,
  ) {
    return snapshot.docs.map((doc) {
      return AttendanceForGroupAndSubject(
        attendanceMap:
            doc.get(ConstantsFirebase.attendanceFieldStudentsAttendance) ??
                {'': ''},
        date: doc.get(ConstantsFirebase.attendanceFieldDate) ?? '',
      );
    }).toList();
  }
}
