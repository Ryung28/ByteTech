import 'package:intl/intl.dart';
import 'chart_state.dart';

class TimeFormatterImpl {
  String formatTimeLabel(DateTime date, TimeRange range) {
    switch (range) {
      case TimeRange.today:
        return DateFormat('HH:mm').format(date);
      case TimeRange.week:
        return DateFormat('E').format(date); // Mon, Tue, etc.
      case TimeRange.month:
        return DateFormat('MMM d').format(date); // Dec 8, etc.
    }
  }

  String formatTooltipTime(DateTime date, TimeRange range) {
    switch (range) {
      case TimeRange.today:
        return DateFormat('MMM d, HH:mm').format(date); // Dec 8, 14:30
      case TimeRange.week:
        return DateFormat('MMM d, E').format(date); // Dec 8, Sun
      case TimeRange.month:
        return DateFormat('MMM d, yyyy').format(date); // Dec 8, 2024
    }
  }
}
