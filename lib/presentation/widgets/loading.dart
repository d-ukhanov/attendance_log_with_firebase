// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_spinkit/flutter_spinkit.dart';

// Project imports:
import 'package:attendance_log_with_firebase/src/constants/constants_ui.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: ConstantsUI.colorBackground,
      child: const Center(
        child: SpinKitChasingDots(color: ConstantsUI.colorEnd),
      ),
    );
  }
}
