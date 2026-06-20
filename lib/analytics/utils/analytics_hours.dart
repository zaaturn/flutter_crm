/// Formats decimal hours from analytics API (e.g. 0.02 → "1m", 1.5 → "1.5h").
abstract final class AnalyticsHours {
  AnalyticsHours._();

  static String format(double hours) {
    if (hours <= 0) return '0h';
    if (hours < 1) return '${(hours * 60).round()}m';
    final oneDecimal = double.parse(hours.toStringAsFixed(1));
    if ((hours - oneDecimal).abs() < 0.001) {
      return '${oneDecimal.toStringAsFixed(1)}h';
    }
    return '${hours.toStringAsFixed(2)}h';
  }
}
