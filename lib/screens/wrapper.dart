import 'package:attendance_log_with_firebase/models/user.dart';
import 'package:attendance_log_with_firebase/screens/authenticate/authenticate.dart';
import 'package:attendance_log_with_firebase/screens/home/home.dart';
import 'package:attendance_log_with_firebase/shared/restart_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    // return either Home or Authenticate widget

    if (user == null) {
      return Authenticate();
    } else {
      return (RestartWidget(child: Home(userId: user.uid)));
    }
  }
}
