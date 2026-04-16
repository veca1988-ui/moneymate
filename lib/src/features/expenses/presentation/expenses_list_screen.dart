import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:moneymate/src/constants/app_colors.dart';
import 'package:moneymate/src/constants/app_sizes.dart';
import 'package:moneymate/src/constants/category_icon.dart';
import 'package:moneymate/src/features/auth/data/firebase_auth_repository.dart';
import 'package:moneymate/src/features/expenses/data/expenses_repository_impl.dart';
import 'package:moneymate/src/features/expenses/domain/expense.dart';
import 'package:moneymate/src/features/expenses/presentation/expenses_controller.dart';
import 'package:moneymate/src/utils/currency_helper.dart';

class ExpensesListScreen extends ConsumerWidget {
  const ExpensesListScreen({
    required this.coupleId,
    required this.month,
    super.key,
  });

  final String coupleId;
  final String month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).valueOrNull;
    final currency = user?.currency ?? 'USD';

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: StreamBuilder<List<Expense>>(
        stream: ref
            .read(expensesRepositoryProvider)
            .watchExpenses(coupleId: coupleId, month: month),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final expenses = snapshot.data ?? [];

          if (expenses.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: Sizes.p16),
                  Text('No expenses yet'),
                ],
              ),
            );
          }

          final grouped = <String, List<Expense>>{};
          for (final expense in expenses) {
            final dateKey = DateFormat('yyyy-MM-dd').format(expense.date);
            grouped.putIfAbsent(dateKey, () => []).add(expense);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(Sizes.p16),
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final dateKey = grouped.keys.elementAt(index);
              final dayExpenses = grouped[dateKey]!;
              final dayTotal =
                  dayExpenses.fold<double>(0, (sum, e) => sum + e.amount);
              final date = DateTime.parse(dateKey);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: Sizes.p8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('EEEE, MMM d').format(date),
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                        Text(
                          CurrencyHelper.formatAmount(dayTotal, currency),
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: AppColors.expense,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  ...dayExpenses.map(
                    (expense) => Dismissible(
                      key: ValueKey(expense.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: Sizes.p16),
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        return showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Expense'),
                            content: const Text(
                              'Are you sure you want to delete this expense?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) {
                        ref
                            .read(expensesControllerProvider.notifier)
                            .deleteExpense(
                              coupleId: coupleId,
                              expenseId: expense.id,
                            );
                      },
                      child: GestureDetector(
                        onTap: () => context.push(
                          '/edit-expense/$coupleId',
                          extra: expense,
                        ),
                        child: _ExpenseListTile(
                          expense: expense,
                          currency: currency,
                        ),
                      ),
                    ),
                  ),
                  const Divider(),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ExpenseListTile extends StatelessWidget {
  const _ExpenseListTile({required this.expense, required this.currency});
  final Expense expense;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CategoryIcon(category: expense.category),
      title: Text(expense.category),
      subtitle: _buildSubtitle(context),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (expense.visibility == 'private')
            const Padding(
              padding: EdgeInsets.only(right: Sizes.p8),
              child: Icon(Icons.lock, size: 16, color: AppColors.warning),
            ),
          Text(
            CurrencyHelper.formatAmount(expense.amount, currency),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget? _buildSubtitle(BuildContext context) {
    final hasName = expense.userName.isNotEmpty;
    final hasNote = expense.note.isNotEmpty;
    if (!hasName && !hasNote) return null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasName)
          Text(
            expense.userName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
        if (hasNote)
          Text(
            expense.note,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
          ),
      ],
    );
  }

}
