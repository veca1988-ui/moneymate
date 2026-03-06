import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/src/features/expenses/domain/expense.dart';

void main() {
  group('Expense', () {
    test('creates expense with required fields', () {
      final expense = Expense(
        id: '1',
        amount: 25.50,
        category: 'Groceries',
        date: DateTime(2026, 3, 5),
        userId: 'user1',
        visibility: 'shared',
        createdAt: DateTime(2026, 3, 5),
      );

      expect(expense.amount, 25.50);
      expect(expense.category, 'Groceries');
      expect(expense.visibility, 'shared');
      expect(expense.note, '');
    });

    test('toJson and fromJson roundtrip preserves data', () {
      final expense = Expense(
        id: '1',
        amount: 42.0,
        category: 'Dining',
        date: DateTime(2026, 3, 5),
        userId: 'user1',
        visibility: 'private',
        createdAt: DateTime(2026, 3, 5),
        note: 'Dinner with friends',
      );

      final json = expense.toJson();
      final restored = Expense.fromJson(json);

      expect(restored, expense);
    });

    test('copyWith creates modified copy', () {
      final expense = Expense(
        id: '1',
        amount: 10.0,
        category: 'Other',
        date: DateTime(2026, 3, 5),
        userId: 'user1',
        visibility: 'shared',
        createdAt: DateTime(2026, 3, 5),
      );

      final modified = expense.copyWith(amount: 20.0);

      expect(modified.amount, 20.0);
      expect(modified.id, '1');
    });
  });
}
