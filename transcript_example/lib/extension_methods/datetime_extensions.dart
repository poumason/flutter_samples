import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String buildWithStandardFormat(String langCode) {
    if (year == DateTime.now().year) {
      return DateFormat('MM/dd', langCode).format(this);
    } else {
      return DateFormat('y/MM/dd', langCode).format(this);
    }
  }
}