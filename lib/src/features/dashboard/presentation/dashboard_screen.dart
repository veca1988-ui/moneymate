import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:moneymate/src/constants/app_colors.dart';
import 'package:moneymate/src/constants/app_sizes.dart';
import 'package:moneymate/src/features/budgets/data/budgets_repository_impl.dart';
import 'package:moneymate/src/features/budgets/domain/budget.dart';
import 'package:moneymate/src/features/dashboard/presentation/budget_progress_card.dart';
import 'package:moneymate/src/features/dashboard/presentation/spending_pie_chart.dart';
import 'package:moneymate/src/features/expenses/data/expenses_repository_impl.dart';
import 'package:moneymate/src/features/expenses/domain/expense.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({
    required this.coupleId,
    super.key,
  });

  final String coupleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final month = DateFormat('yyyy-MM').format(now);
    final monthDisplay = DateFormat('MMMM yyyy').format(now);

    return Scaffold(
      appBar: AppBar(
        title: Text(monthDisplay),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: StreamBuilder<List<Expense>>(
        stream: ref
            .read(expensesRepositoryProvider)
            .watchExpenses(coupleId: coupleId, month: month),
        builder: (context, expenseSnapshot) {
          final expenses = expenseSnapshot.data ?? [];
          final totalSpent =
              expenses.fold<double>(0, (total, e) => total + e.amount);

          final categoryTotals = <String, double>{};
          for (final expense in expenses) {
            categoryTotals[expense.category] =
                (categoryTotals[expense.category] ?? 0) + expense.amount;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(Sizes.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(Sizes.p24),
                    child: Column(
                      children: [
                        Text(
                          'Total Spent',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: Sizes.p8),
                        Text(
                          '\$${totalSpent.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.expense,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Sizes.p16),
                if (categoryTotals.isNotEmpty)
                  SpendingPieChart(categoryTotals: categoryTotals),
                const SizedBox(height: Sizes.p24),
                Text(
                  'Budgets',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: Sizes.p12),
                StreamBuilder<List<Budget>>(
                  stream: ref
                      .read(budgetsRepositoryProvider)
                      .watchBudgets(coupleId: coupleId, month: month),
                  builder: (context, budgetSnapshot) {
                    final budgets = budgetSnapshot.data ?? [];

                    if (budgets.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(Sizes.p24),
                          child: Center(
                            child: Text('No budgets set. Tap + to create one.'),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: budgets.map((budget) {
                        final spent = categoryTotals[budget.category] ?? 0;
                        return BudgetProgressCard(
                          budget: budget,
                          spent: spent,
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (ctx) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.receipt_long),
                    title: const Text('Add Expense'),
                    onTap: () {
                      Navigator.pop(ctx);
                      context.push('/add-expense/$coupleId');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.savings),
                    title: const Text('Add Budget'),
                    onTap: () {
                      Navigator.pop(ctx);
                      context.push('/add-budget/$coupleId');
                    },
                  ),
                ],
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.list), label: 'Expenses'),
          NavigationDestination(
            icon: Icon(Icons.pie_chart),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              break; // Already on Home
            case 1:
              context.push('/expenses/$coupleId');
            case 2:
              // Reports — same as home for now
              break;
            case 3:
              context.push('/settings');
          }
        },
      ),
    );
  }
}
