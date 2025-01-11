import 'package:intl/intl.dart';
import 'chart_state.dart';

mixin TimeFormatterMixin {
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
        return DateFormat('HH:mm').format(date);
      case TimeRange.week:
        return DateFormat('MMM d, HH:mm').format(date);
      case TimeRange.month:
        return DateFormat('MMM d').format(date);
    }
  }
}
