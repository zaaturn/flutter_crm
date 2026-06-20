import 'package:intl/intl.dart';

/// Parses API money fields that may arrive as `"120000.00"` strings or numbers.
abstract final class AnalyticsMoney {
  AnalyticsMoney._();

  static double? parse(dynamic raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    final s = raw.toString().trim().replaceAll(',', '');
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }

  static String format(
    dynamic raw, {
    String symbol = '₹',
    int fractionDigits = 2,
  }) {
    final value = parse(raw);
    if (value == null) return '—';
    final fmt = NumberFormat.currency(
      locale: 'en_IN',
      symbol: symbol,
      decimalDigits: fractionDigits,
    );
    return fmt.format(value);
  }
}
