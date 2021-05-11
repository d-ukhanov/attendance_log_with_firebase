import 'package:attendance_log_with_firebase/screens/wrapper.dart';
import 'package:attendance_log_with_firebase/services/auth.dart';
import 'package:attendance_log_with_firebase/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendance_log_with_firebase/shared/restart_widget.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(RestartWidget(child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate
        ],
        supportedLocales: [
          const Locale('en'),
          const Locale('ru')
        ],
        debugShowCheckedModeBanner: false,
        home: Wrapper(),
      ),
    );
  }
}
