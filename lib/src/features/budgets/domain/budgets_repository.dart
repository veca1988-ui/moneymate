import 'package:moneymate/src/features/budgets/domain/budget.dart';

abstract class BudgetsRepository {
  Stream<List<Budget>> watchBudgets({
    required String coupleId,
    required String month,
  });

  Future<void> setBudget({
    required String coupleId,
    required Budget budget,
  });

  Future<void> deleteBudget({
    required String coupleId,
    required String budgetId,
  });
}
