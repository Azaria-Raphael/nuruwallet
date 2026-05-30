import 'package:intl/intl.dart';

/// Formats monetary amounts for display throughout the app.
/// Handles TZS (no decimals) and all other ISO 4217 currencies.
/// All methods are safe against NaN, infinity, and astronomically large values.
abstract final class CurrencyFormatter {
  static final Map<String, NumberFormat> _cache = {};

  // Clamp display to 10 trillion — beyond this numbers are formatted compactly
  // to avoid breaking card layouts.
  static const _maxDisplay = 9_999_999_999_999.0;

  static double _sanitize(double v) {
    if (!v.isFinite) return 0.0;
    final abs = v.abs();
    return abs > _maxDisplay ? _maxDisplay * (v.isNegative ? -1.0 : 1.0) : v;
  }

  /// Full format with currency symbol: "TZS 150,000" or "USD 12.50".
  static String format(double amount, {String currencyCode = 'TZS'}) {
    return _getFormatter(currencyCode).format(_sanitize(amount));
  }

  /// Compact notation for tight spaces: "1.5M", "250K", "45,000".
  /// Does NOT include the currency symbol — suitable for small cards and labels.
  static String formatCompact(double amount, {String currencyCode = 'TZS'}) {
    final safe = _sanitize(amount);
    final abs = safe.abs();
    final sign = safe < 0 ? '-' : '';
    if (abs >= 1e12) return '$sign${(abs / 1e12).toStringAsFixed(1)}T';
    if (abs >= 1e9)  return '$sign${(abs / 1e9).toStringAsFixed(1)}B';
    if (abs >= 1e6)  return '$sign${(abs / 1e6).toStringAsFixed(1)}M';
    if (abs >= 1e3)  return '$sign${(abs / 1e3).toStringAsFixed(0)}K';
    return '$sign${NumberFormat('#,##0', 'en_US').format(abs.round())}';
  }

  /// Signed format: "+TZS 5,000" or "-TZS 3,000".
  static String formatWithSign(double amount, {String currencyCode = 'TZS'}) {
    final prefix = amount >= 0 ? '+' : '';
    return '$prefix${format(amount, currencyCode: currencyCode)}';
  }

  static NumberFormat _getFormatter(String currencyCode) {
    return _cache.putIfAbsent(currencyCode, () {
      if (currencyCode == 'TZS') {
        return NumberFormat.currency(
          locale: 'sw_TZ',
          symbol: 'TZS ',
          decimalDigits: 0,
        );
      }
      return NumberFormat.currency(
        symbol: '$currencyCode ',
        decimalDigits: 2,
      );
    });
  }
}
