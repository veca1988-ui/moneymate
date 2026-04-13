class CurrencyHelper {
  static const _symbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'RSD': 'RSD',
    'CAD': 'C\$',
    'AUD': 'A\$',
  };

  static const _noDecimals = {'RSD'};

  static String symbol(String currencyCode) {
    return _symbols[currencyCode] ?? currencyCode;
  }

  static String formatAmount(double amount, String currencyCode) {
    final sym = symbol(currencyCode);
    if (_noDecimals.contains(currencyCode)) {
      return '${amount.round()} $sym';
    }
    return '$sym${amount.toStringAsFixed(2)}';
  }
}
