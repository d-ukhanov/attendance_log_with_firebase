import 'package:flutter/material.dart';
import 'package:attendance_log_with_firebase/shared/constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorBackground,
      child: Center(
        child: SpinKitChasingDots(
          color: colorEnd,
          size: 50.0,
        ),
      ),
    );
  }
}
