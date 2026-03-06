import 'package:moneymate/src/features/expenses/domain/expense.dart';

abstract class ExpensesRepository {
  Stream<List<Expense>> watchExpenses({
    required String coupleId,
    required String month,
    String? category,
  });

  Stream<List<Expense>> watchVisibleExpenses({
    required String coupleId,
    required String month,
    required String currentUserId,
    required Map<String, String> partnerPrivacySettings,
  });

  Future<void> addExpense({
    required String coupleId,
    required Expense expense,
  });

  Future<void> updateExpense({
    required String coupleId,
    required Expense expense,
  });

  Future<void> deleteExpense({
    required String coupleId,
    required String expenseId,
  });

  Future<double> getCategoryTotal({
    required String coupleId,
    required String month,
    required String category,
  });
}
