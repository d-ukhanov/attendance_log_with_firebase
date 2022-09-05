// Package imports:
import 'package:get_it/get_it.dart';

// Project imports:
import 'package:attendance_log_with_firebase/core/data/repositories/groups_repository_impl.dart';
import 'package:attendance_log_with_firebase/core/data/repositories/observers_repository_impl.dart';
import 'package:attendance_log_with_firebase/core/data/repositories/students_repository_impl.dart';
import 'package:attendance_log_with_firebase/core/data/repositories/subjects_repository_impl.dart';
import 'package:attendance_log_with_firebase/core/data/repositories/attendance_repository_impl.dart';
import 'package:attendance_log_with_firebase/core/data/repositories/auth_repository_impl.dart';
import 'package:attendance_log_with_firebase/core/domain/repositories/auth_repository.dart';
import 'package:attendance_log_with_firebase/core/domain/repositories/groups_repository.dart';
import 'package:attendance_log_with_firebase/core/domain/repositories/observers_repository.dart';
import 'package:attendance_log_with_firebase/core/domain/repositories/students_repository.dart';
import 'package:attendance_log_with_firebase/core/domain/repositories/subjects_repository.dart';
import 'package:attendance_log_with_firebase/core/domain/repositories/attendance_repository.dart';

mixin RepositoriesDI {
  static void init() {
    GetIt.I.registerSingletonAsync<AuthRepository>(
      () async => AuthRepositoryImpl(),
    );

    GetIt.I.registerSingletonAsync<AttendanceRepository>(
          () async => AttendanceRepositoryImpl(),
    );

    GetIt.I.registerSingletonAsync<GroupsRepository>(
          () async => GroupsRepositoryImpl(),
    );

    GetIt.I.registerSingletonAsync<ObserversRepository>(
          () async => ObserversRepositoryImpl(),
    );

    GetIt.I.registerSingletonAsync<StudentsRepository>(
          () async => StudentsRepositoryImpl()
    );

    GetIt.I.registerSingletonAsync<SubjectsRepository>(
          () async => SubjectsRepositoryImpl(),
    );
  }
}
