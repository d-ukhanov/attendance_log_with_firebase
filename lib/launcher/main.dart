// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';

// Project imports:
import 'package:attendance_log_with_firebase/di/repositories_di.dart';
import 'package:attendance_log_with_firebase/firebase_options.dart';
import 'package:attendance_log_with_firebase/presentation/pages/wrapper.dart';
import 'package:attendance_log_with_firebase/utils/logger.dart';

Future<void> _setup() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Log.init();

  RepositoriesDI.init();
  await GetIt.I.allReady();
}

Future<void> main() async {
  await _setup();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ru')],
      debugShowCheckedModeBanner: false,
      home: Wrapper(),
    );
  }
}
