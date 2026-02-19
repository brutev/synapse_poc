import 'package:intl/intl.dart';

class DateFormatUtils {
  const DateFormatUtils._();

  static String format(DateTime value) =>
      DateFormat('dd-MM-yyyy').format(value);
}
