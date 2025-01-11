import 'package:intl/intl.dart';
import 'chart_state.dart';
import 'time_formatter_mixin.dart';

class TimeFormatterImpl with TimeFormatterMixin {
  static final TimeFormatterImpl _instance = TimeFormatterImpl._internal();
  
  factory TimeFormatterImpl() {
    return _instance;
  }

  TimeFormatterImpl._internal();
}
