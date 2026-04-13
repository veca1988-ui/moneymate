import 'package:moneymate/src/features/auth/data/firebase_auth_repository.dart';
import 'package:moneymate/src/features/expenses/data/expenses_repository_impl.dart';
import 'package:moneymate/src/features/expenses/domain/expense.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'expenses_controller.g.dart';

@riverpod
class ExpensesController extends _$ExpensesController {
  @override
  FutureOr<void> build() {}

  Future<bool> addExpense({
    required String coupleId,
    required double amount,
    required String category,
    required String visibility,
    String note = '',
    DateTime? date,
  }) async {
    final userId = ref.read(firebaseAuthRepositoryProvider).currentUserId!;
    final user = ref.read(authStateChangesProvider).valueOrNull;
    final userName = user?.name ?? '';
    final now = DateTime.now();

    final expense = Expense(
      id: '',
      amount: amount,
      category: category,
      date: date ?? now,
      userId: userId,
      visibility: visibility,
      createdAt: now,
      note: note,
      userName: userName,
    );

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(expensesRepositoryProvider).addExpense(
            coupleId: coupleId,
            expense: expense,
          ),
    );

    return !state.hasError;
  }

  Future<bool> updateExpense({
    required String coupleId,
    required Expense expense,
  }) async {
    final repo = ref.read(expensesRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => repo.updateExpense(coupleId: coupleId, expense: expense),
    );
    return !state.hasError;
  }

  Future<bool> deleteExpense({
    required String coupleId,
    required String expenseId,
  }) async {
    final repo = ref.read(expensesRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => repo.deleteExpense(coupleId: coupleId, expenseId: expenseId),
    );
    return !state.hasError;
  }
}
