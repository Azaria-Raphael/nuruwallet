import 'package:intl/intl.dart';

/// Date display helpers used throughout the app.
abstract final class DateFormatter {
  static final _monthYear = DateFormat('MMMM yyyy');
  static final _dayMonth = DateFormat('d MMM');
  static final _full = DateFormat('d MMM yyyy');
  static final _time = DateFormat('HH:mm');
  static final _shortDt = DateFormat('d MMM, HH:mm');
  static final _fullDt = DateFormat('d MMM yyyy, HH:mm');
  static final _iso = DateFormat('yyyy-MM-dd');

  /// "May 2026"
  static String monthYear(DateTime dt) => _monthYear.format(dt);

  /// "15 May"
  static String dayMonth(DateTime dt) => _dayMonth.format(dt);

  /// "15 May 2026"
  static String full(DateTime dt) => _full.format(dt);

  /// "08:15"
  static String time(DateTime dt) => _time.format(dt);

  /// "15 May, 10:30"  — date + time, compact (no year)
  static String dateTime(DateTime dt) => _shortDt.format(dt);

  /// "15 May 2026, 10:30"  — date + time with year, for exports
  static String dateTimeFull(DateTime dt) => _fullDt.format(dt);

  /// "2026-05-15"
  static String iso(DateTime dt) => _iso.format(dt);

  /// Returns "Today", "Yesterday", or "15 May 2026" for list group headers.
  static String groupHeader(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return DateFormat('EEEE').format(dt); // "Monday"
    return full(dt);
  }

  /// How many days remain until [deadline]. Negative means overdue.
  static int daysUntil(DateTime deadline) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(deadline.year, deadline.month, deadline.day);
    return target.difference(today).inDays;
  }
}
