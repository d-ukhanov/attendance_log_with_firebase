import 'package:flutter/material.dart';

final colorAppBarTween = ColorTween(begin: colorBegin, end: colorEnd);

final colorBegin = Color.fromRGBO(13, 48, 253, 1);
final colorEnd = Color.fromRGBO(153, 52, 255, 1);

final colorBackground = Colors.blue[100];

final textInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width: 2.0)),
  focusedBorder:
      OutlineInputBorder(borderSide: BorderSide(color: colorEnd, width: 2.0)),
);
