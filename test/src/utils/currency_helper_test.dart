import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/src/utils/currency_helper.dart';

void main() {
  group('CurrencyHelper', () {
    test('formatAmount returns correct symbol for USD', () {
      expect(CurrencyHelper.formatAmount(42.5, 'USD'), r'$42.50');
    });
    test('formatAmount returns correct symbol for EUR', () {
      expect(CurrencyHelper.formatAmount(42.5, 'EUR'), '€42.50');
    });
    test('formatAmount returns correct symbol for GBP', () {
      expect(CurrencyHelper.formatAmount(42.5, 'GBP'), '£42.50');
    });
    test('formatAmount returns correct symbol for RSD', () {
      expect(CurrencyHelper.formatAmount(42.5, 'RSD'), '43 RSD');
    });
    test('formatAmount returns correct symbol for CAD', () {
      expect(CurrencyHelper.formatAmount(42.5, 'CAD'), r'C$42.50');
    });
    test('formatAmount returns correct symbol for AUD', () {
      expect(CurrencyHelper.formatAmount(42.5, 'AUD'), r'A$42.50');
    });
    test('symbol returns just the symbol', () {
      expect(CurrencyHelper.symbol('USD'), r'$');
      expect(CurrencyHelper.symbol('EUR'), '€');
      expect(CurrencyHelper.symbol('RSD'), 'RSD');
    });
    test('formatAmount with 0 returns zero formatted correctly', () {
      expect(CurrencyHelper.formatAmount(0, 'USD'), r'$0.00');
      expect(CurrencyHelper.formatAmount(0, 'EUR'), '€0.00');
    });
    test('formatAmount with very large number formats correctly', () {
      expect(CurrencyHelper.formatAmount(1000000, 'USD'), r'$1000000.00');
      expect(CurrencyHelper.formatAmount(9999999.99, 'GBP'), '£9999999.99');
    });
    test('symbol returns currency code itself for unknown currency code', () {
      expect(CurrencyHelper.symbol('XYZ'), 'XYZ');
      expect(CurrencyHelper.symbol('JPY'), 'JPY');
    });
  });
}
