/// Device-local, English formatting without a runtime package dependency.
abstract final class DateTimeFormatters {
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  static const _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static String _two(int value) => value.toString().padLeft(2, '0');
  static String clock(DateTime value) {
    final local = value.toLocal();
    return '${_two(local.hour)}:${_two(local.minute)}:${_two(local.second)}';
  }

  static String time(DateTime? value) {
    if (value == null) return '—';
    final local = value.toLocal();
    return '${_two(local.hour)}:${_two(local.minute)}';
  }

  static String fullDate(DateTime value) {
    final local = value.toLocal();
    return '${_weekdays[local.weekday - 1]}, '
        '${_months[local.month - 1]} ${local.day}, ${local.year}';
  }

  static String shortDate(DateTime value) {
    final local = value.toLocal();
    return '${_months[local.month - 1].substring(0, 3)} ${local.day}, ${local.year}';
  }

  static String hours(Duration value) =>
      '${value.inHours}h ${_two(value.inMinutes.remainder(60))}m';

  static String greeting(DateTime value) => switch (value.toLocal().hour) {
    < 12 => 'Good morning',
    < 17 => 'Good afternoon',
    _ => 'Good evening',
  };
}
