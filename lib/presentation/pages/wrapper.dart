// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get_it/get_it.dart';

// Project imports:
import 'package:attendance_log_with_firebase/core/domain/repositories/auth_repository.dart';
import 'package:attendance_log_with_firebase/core/domain/models/user.dart';
import 'package:attendance_log_with_firebase/presentation/pages/authenticate/login/login.dart';
import 'package:attendance_log_with_firebase/presentation/pages/home/home.dart';
import 'package:attendance_log_with_firebase/presentation/widgets/restart_widget.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthRepository authRepository = GetIt.I.get();

    return StreamBuilder<User?>(
      stream: authRepository.authStateChanges,
      builder: (context, userSnap) {
        if (userSnap.hasData) {
          return RestartWidget(child: HomePage(userId: userSnap.data!.uid));
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
