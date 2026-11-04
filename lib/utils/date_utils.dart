import 'package:intl/intl.dart';

class AppDateUtils {
  static String toDateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static DateTime parseDateKey(String key) {
    final parts = key.split('-');
    if (parts.length != 3) return DateTime.now();
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  static DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// Returns the Monday of the week containing [date]
  static DateTime getStartOfWeek(DateTime date) {
    final normalized = normalizeDate(date);
    // weekday is 1 for Monday, 7 for Sunday
    return normalized.subtract(Duration(days: normalized.weekday - 1));
  }

  /// Returns the 7 days (Monday..Sunday) of the week
  static List<DateTime> getDaysOfWeek(DateTime date) {
    final monday = getStartOfWeek(date);
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  /// Returns all days of [month] in [year]
  static List<DateTime> getDaysInMonth(int year, int month) {
    final daysCount = DateTime(year, month + 1, 0).day;
    return List.generate(
      daysCount,
      (index) => DateTime(year, month, index + 1),
    );
  }

  static String formatVietnameseWeekday(int weekday, {bool short = false}) {
    switch (weekday) {
      case DateTime.monday:
        return short ? 'T2' : 'Thứ Hai';
      case DateTime.tuesday:
        return short ? 'T3' : 'Thứ Ba';
      case DateTime.wednesday:
        return short ? 'T4' : 'Thứ Tư';
      case DateTime.thursday:
        return short ? 'T5' : 'Thứ Năm';
      case DateTime.friday:
        return short ? 'T6' : 'Thứ Sáu';
      case DateTime.saturday:
        return short ? 'T7' : 'Thứ Bảy';
      case DateTime.sunday:
        return short ? 'CN' : 'Chủ Nhật';
      default:
        return '';
    }
  }

  static String formatDisplayFullDate(DateTime date) {
    final weekday = formatVietnameseWeekday(date.weekday);
    final dateStr = DateFormat('dd/MM/yyyy').format(date);
    if (isToday(date)) {
      return 'Hôm nay - $weekday ($dateStr)';
    }
    return '$weekday, $dateStr';
  }
}
