// Package imports:
import 'package:logger/logger.dart';

mixin Log {
  static late Logger logger;

  static void init() {
    logger = Logger();
  }
}
