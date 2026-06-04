import 'package:intl/intl.dart';

class DateTimeFormatter {
  static String formatDate(String rawDate) {
    try {
      final date = DateTime.parse(rawDate);
      return DateFormat('MMM dd, yyyy').format(date); // "May 29, 2026"
    } catch (e) {
      return rawDate; // fallback to raw if parse fails
    }
  }

  static String formatTime(String rawDate) {
    try {
      final date = DateTime.parse(rawDate);
      return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return rawDate; // fallback to raw if parse fails
    }
  }
}
