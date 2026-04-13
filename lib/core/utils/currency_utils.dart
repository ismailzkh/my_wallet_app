import 'package:intl/intl.dart';

enum AppCurrency {
  iqd,
  usd,
}

class CurrencyUtils {
  static AppCurrency currentCurrency = AppCurrency.iqd;

  static String format(num amount) {
    final config = _config(currentCurrency);

    return NumberFormat.currency(
      locale: config.locale,
      name: config.code,
      symbol: config.symbol,
      decimalDigits: config.decimalDigits,
    ).format(amount);
  }

  static String compactPlain(num amount) {
  final value = amount.abs();

  if (value >= 1000000) {
    final short = (value / 1000000).toStringAsFixed(1);
    return '${amount < 0 ? '-' : ''}${_trimZero(short)}M';
  }

  if (value >= 1000) {
    final short = (value / 1000).toStringAsFixed(1);
    return '${amount < 0 ? '-' : ''}${_trimZero(short)}k';
  }

  if (decimalDigits == 0) {
    return '${amount < 0 ? '-' : ''}${value.toStringAsFixed(0)}';
  }

  return '${amount < 0 ? '-' : ''}${_trimZero(value.toStringAsFixed(1))}';
}

  static String code() => _config(currentCurrency).code;

  static String get symbol => _config(currentCurrency).symbol;

  static int get decimalDigits => _config(currentCurrency).decimalDigits;

  static String compact(num amount) {
    final config = _config(currentCurrency);
    final value = amount.abs();

    if (value >= 1000000) {
      final short = (value / 1000000).toStringAsFixed(1);
      return '${amount < 0 ? '-' : ''}${config.symbol}${_trimZero(short)}M';
    }

    if (value >= 1000) {
      final short = (value / 1000).toStringAsFixed(1);
      return '${amount < 0 ? '-' : ''}${config.symbol}${_trimZero(short)}k';
    }

    return '${amount < 0 ? '-' : ''}${format(value)}';
  }

  static _CurrencyConfig _config(AppCurrency currency) {
    switch (currency) {
      case AppCurrency.iqd:
        return const _CurrencyConfig(
          code: 'IQD',
          symbol: 'IQD ',
          locale: 'en_US',
          decimalDigits: 0,
        );
      case AppCurrency.usd:
        return const _CurrencyConfig(
          code: 'USD',
          symbol: r'$',
          locale: 'en_US',
          decimalDigits: 2,
        );
    }
  }

  static String _trimZero(String value) {
    if (value.endsWith('.0')) {
      return value.substring(0, value.length - 2);
    }
    return value;
  }
}

class _CurrencyConfig {
  final String code;
  final String symbol;
  final String locale;
  final int decimalDigits;

  const _CurrencyConfig({
    required this.code,
    required this.symbol,
    required this.locale,
    required this.decimalDigits,
  });
}