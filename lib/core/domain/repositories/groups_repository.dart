// Project imports:
import 'package:attendance_log_with_firebase/core/domain/models/group.dart';

abstract class GroupsRepository {
  Stream<List<Group>> groupsByIds(List<String> groupIds);
}
