// Project imports:
import 'package:attendance_log_with_firebase/core/domain/models/student.dart';

abstract class AttendanceRepository {
  /// Attendance stream
  Stream<List<AttendanceForGroupAndSubject>> attendanceForGroupAndSubject(
    String groupId,
    String subjectId, {
    required String startDate,
    required String endDate,
  });

  ///Create or update an existing document in firebase with student attendance data for a specific lesson
  Future<void> updateAttendanceForStudent(
    String date,
    String groupId,
    String subjectId, {
    String studentId = '',
    String state = '',
    String? changeDate,
    List<String>? groupStudentIds,
  });

  /// Delete document in firebase with student attendance data for a specific lesson
  Future deleteAttendanceForStudent(
    String date,
    String groupId,
    String subjectId,
  );

  Future<String> getLastEntryDate();
}
