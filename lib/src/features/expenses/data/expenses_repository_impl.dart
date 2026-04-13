import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moneymate/src/features/auth/data/firebase_auth_repository.dart';
import 'package:moneymate/src/features/expenses/domain/expense.dart';
import 'package:moneymate/src/features/expenses/domain/expenses_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'expenses_repository_impl.g.dart';

@Riverpod(keepAlive: true)
ExpensesRepositoryImpl expensesRepository(ExpensesRepositoryRef ref) {
  return ExpensesRepositoryImpl(ref.watch(firestoreProvider));
}

class ExpensesRepositoryImpl implements ExpensesRepository {
  ExpensesRepositoryImpl(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _expensesRef(String coupleId) =>
      _firestore.collection('couples').doc(coupleId).collection('expenses');

  @override
  Stream<List<Expense>> watchExpenses({
    required String coupleId,
    required String month,
    String? category,
  }) {
    final startDate = DateTime.parse('$month-01');
    final endDate = DateTime(startDate.year, startDate.month + 1);

    var query = _expensesRef(coupleId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThan: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true);

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map(
          (snapshot) => snapshot.docs.map(Expense.fromFirestore).toList(),
        );
  }

  @override
  Stream<List<Expense>> watchVisibleExpenses({
    required String coupleId,
    required String month,
    required String currentUserId,
    required Map<String, String> partnerPrivacySettings,
  }) {
    return watchExpenses(coupleId: coupleId, month: month).map((expenses) {
      return expenses.where((expense) {
        if (expense.userId == currentUserId) return true;
        final visibility = partnerPrivacySettings[expense.category] ?? 'all';
        if (visibility == 'private') return false;
        if (visibility == 'total') return false;
        return true;
      }).toList();
    });
  }

  @override
  Future<void> addExpense({
    required String coupleId,
    required Expense expense,
  }) async {
    await _expensesRef(coupleId).add(expense.toFirestore());
  }

  @override
  Future<void> updateExpense({
    required String coupleId,
    required Expense expense,
  }) async {
    await _expensesRef(coupleId).doc(expense.id).update(expense.toFirestore());
  }

  @override
  Future<void> deleteExpense({
    required String coupleId,
    required String expenseId,
  }) async {
    await _expensesRef(coupleId).doc(expenseId).delete();
  }

  @override
  Future<double> getCategoryTotal({
    required String coupleId,
    required String month,
    required String category,
  }) async {
    final startDate = DateTime.parse('$month-01');
    final endDate = DateTime(startDate.year, startDate.month + 1);

    final snapshot = await _expensesRef(coupleId)
        .where('category', isEqualTo: category)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThan: Timestamp.fromDate(endDate))
        .get();

    return snapshot.docs.fold<double>(
      0,
      (total, doc) => total + (doc.data()['amount'] as num).toDouble(),
    );
  }
}
