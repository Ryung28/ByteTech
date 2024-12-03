import 'chart_state.dart';

mixin TimeFormatterMixin {
  String formatTimeLabel(DateTime date, TimeRange range) {
    switch (range) {
      case TimeRange.today:
        final hour = date.hour;
        if (hour == 0) return '12AM';
        if (hour == 12) return '12PM';
        return hour > 12 ? '${hour - 12}PM' : '${hour}AM';
      
      case TimeRange.week:
        final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        return days[date.weekday % 7];
      
      case TimeRange.month:
        return '${date.day}/${date.month}';
    }
  }

  String formatTooltipTime(DateTime date, TimeRange range) {
    switch (range) {
      case TimeRange.today:
        final hour = date.hour;
        final minute = date.minute.toString().padLeft(2, '0');
        final period = hour < 12 ? 'AM' : 'PM';
        final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        return '$displayHour:$minute $period';
      
      case TimeRange.week:
        final days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
        return '${days[date.weekday % 7]}, ${date.day}';
      
      case TimeRange.month:
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return '${date.day} ${months[date.month - 1]}';
    }
  }
}
