import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moneymate/src/features/auth/data/firebase_auth_repository.dart';
import 'package:moneymate/src/features/budgets/domain/budget.dart';
import 'package:moneymate/src/features/budgets/domain/budgets_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budgets_repository_impl.g.dart';

@Riverpod(keepAlive: true)
BudgetsRepositoryImpl budgetsRepository(BudgetsRepositoryRef ref) {
  return BudgetsRepositoryImpl(ref.watch(firestoreProvider));
}

class BudgetsRepositoryImpl implements BudgetsRepository {
  BudgetsRepositoryImpl(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _budgetsRef(String coupleId) =>
      _firestore.collection('couples').doc(coupleId).collection('budgets');

  @override
  Stream<List<Budget>> watchBudgets({
    required String coupleId,
    required String month,
  }) {
    return _budgetsRef(coupleId)
        .where('month', isEqualTo: month)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            return Budget.fromFirestore(doc.data(), doc.id);
          }).toList(),
        );
  }

  @override
  Future<void> setBudget({
    required String coupleId,
    required Budget budget,
  }) async {
    if (budget.id.isEmpty) {
      await _budgetsRef(coupleId).add({
        'category': budget.category,
        'limit': budget.limit,
        'month': budget.month,
      });
    } else {
      await _budgetsRef(coupleId).doc(budget.id).update({
        'category': budget.category,
        'limit': budget.limit,
        'month': budget.month,
      });
    }
  }

  @override
  Future<void> deleteBudget({
    required String coupleId,
    required String budgetId,
  }) async {
    await _budgetsRef(coupleId).doc(budgetId).delete();
  }
}
