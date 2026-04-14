import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/src/features/budgets/domain/budget.dart';

void main() {
  group('Budget', () {
    test('creates budget with required fields', () {
      final budget = Budget(
        id: 'b1',
        category: 'Groceries',
        limit: 500.0,
        month: '2026-04',
      );

      expect(budget.id, 'b1');
      expect(budget.category, 'Groceries');
      expect(budget.limit, 500.0);
      expect(budget.month, '2026-04');
    });

    test('toJson and fromJson roundtrip preserves data', () {
      final budget = Budget(
        id: 'b2',
        category: 'Dining',
        limit: 200.0,
        month: '2026-03',
      );

      final json = budget.toJson();
      final restored = Budget.fromJson(json);

      expect(restored, budget);
    });

    test('copyWith creates modified copy', () {
      final budget = Budget(
        id: 'b3',
        category: 'Transport',
        limit: 150.0,
        month: '2026-04',
      );

      final modified = budget.copyWith(limit: 300.0);

      expect(modified.limit, 300.0);
      expect(modified.id, 'b3');
      expect(modified.category, 'Transport');
      expect(modified.month, '2026-04');
    });
  });
}
