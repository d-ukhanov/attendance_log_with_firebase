// Project imports:
import 'package:attendance_log_with_firebase/core/domain/models/student.dart';

abstract class StudentsRepository {
  Stream<List<Student>> studentsForGroup(String groupId);
}
