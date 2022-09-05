// Flutter imports:
import 'package:flutter/material.dart';

mixin ConstantsUI {
  static final colorAppBarTween = ColorTween(begin: colorBegin, end: colorEnd);

  static const gradientColors = [colorBegin, colorEnd];
  static const colorBegin = Color.fromRGBO(13, 48, 253, 1);
  static const colorEnd = Color.fromRGBO(153, 52, 255, 1);

  static final colorBackground = Colors.blue.shade100;

  static final InputDecoration textInputDecoration = InputDecoration(
    fillColor: Colors.white,
    filled: true,
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: colorEnd.withOpacity(0.4), width: 2.0),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: colorEnd, width: 2.0),
    ),
  );
}
