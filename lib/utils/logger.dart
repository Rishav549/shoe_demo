import 'package:logger/logger.dart';

class CustomLogger {
  static void debug(Object message) {
    Logger().d(message);
  }

  static void error(Object message) {
    Logger().e(message);
  }

  static void info(Object message) {
    Logger().i(message);
  }
}
