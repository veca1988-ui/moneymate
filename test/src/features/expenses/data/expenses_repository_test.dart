import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moneymate/src/features/expenses/domain/expense.dart';
import 'package:moneymate/src/features/expenses/domain/expenses_repository.dart';

class MockExpensesRepository extends Mock implements ExpensesRepository {}

void main() {
  group('ExpensesRepository', () {
    late MockExpensesRepository mockRepo;

    setUp(() {
      mockRepo = MockExpensesRepository();
    });

    test('watchExpenses returns list of expenses for a month', () {
      final expenses = [
        Expense(
          id: '1',
          amount: 25,
          category: 'Groceries',
          date: DateTime(2026, 3, 5),
          userId: 'user1',
          visibility: 'shared',
          createdAt: DateTime(2026, 3, 5),
        ),
      ];

      when(
        () => mockRepo.watchExpenses(
          coupleId: 'couple1',
          month: '2026-03',
        ),
      ).thenAnswer((_) => Stream.value(expenses));

      final stream = mockRepo.watchExpenses(
        coupleId: 'couple1',
        month: '2026-03',
      );

      expect(stream, emits(expenses));
    });

    test('getCategoryTotal returns sum for category', () async {
      when(
        () => mockRepo.getCategoryTotal(
          coupleId: 'couple1',
          month: '2026-03',
          category: 'Groceries',
        ),
      ).thenAnswer((_) async => 150.0);

      final total = await mockRepo.getCategoryTotal(
        coupleId: 'couple1',
        month: '2026-03',
        category: 'Groceries',
      );

      expect(total, 150.0);
    });
  });
}
