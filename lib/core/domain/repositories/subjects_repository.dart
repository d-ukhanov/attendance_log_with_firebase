// Project imports:
import 'package:attendance_log_with_firebase/core/domain/models/subject.dart';

abstract class SubjectsRepository {
  Stream<List<Subject>> subjectsForGroup(String groupId);
}
