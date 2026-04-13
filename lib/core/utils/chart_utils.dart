import 'currency_utils.dart';

class ChartUtils {
  static bool showDayLabel(int day, int daysInMonth) {
    return day == 1 || day == daysInMonth || day % 5 == 0;
  }

  static String formatMoneyAxis(double value) {
    return CurrencyUtils.compact(value);
  }
}