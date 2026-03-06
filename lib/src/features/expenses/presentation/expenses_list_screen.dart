import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:moneymate/src/constants/app_colors.dart';
import 'package:moneymate/src/constants/app_sizes.dart';
import 'package:moneymate/src/features/expenses/data/expenses_repository_impl.dart';
import 'package:moneymate/src/features/expenses/domain/expense.dart';

class ExpensesListScreen extends ConsumerWidget {
  const ExpensesListScreen({
    super.key,
    required this.coupleId,
    required this.month,
  });

  final String coupleId;
  final String month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<List<Expense>>(
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
                        '\$${dayTotal.toStringAsFixed(2)}',
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
                  (expense) => _ExpenseListTile(expense: expense),
                ),
                const Divider(),
              ],
            );
          },
        );
      },
    );
  }
}

class _ExpenseListTile extends StatelessWidget {
  const _ExpenseListTile({required this.expense});
  final Expense expense;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Icon(
          _categoryIcon(expense.category),
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(expense.category),
      subtitle: expense.note.isNotEmpty ? Text(expense.note) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (expense.visibility == 'private')
            const Padding(
              padding: EdgeInsets.only(right: Sizes.p8),
              child: Icon(Icons.lock, size: 16, color: AppColors.warning),
            ),
          Text(
            '\$${expense.amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    return switch (category) {
      'Groceries' => Icons.shopping_cart,
      'Dining' => Icons.restaurant,
      'Transport' => Icons.directions_car,
      'Bills' => Icons.receipt_long,
      'Entertainment' => Icons.movie,
      'Shopping' => Icons.shopping_bag,
      'Health' => Icons.local_hospital,
      _ => Icons.more_horiz,
    };
  }
}
