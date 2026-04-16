import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:moneymate/src/constants/app_colors.dart';
import 'package:moneymate/src/constants/app_sizes.dart';
import 'package:moneymate/src/features/auth/data/firebase_auth_repository.dart';
import 'package:moneymate/src/features/budgets/data/budgets_repository_impl.dart';
import 'package:moneymate/src/features/budgets/domain/budget.dart';
import 'package:moneymate/src/features/dashboard/presentation/budget_progress_card.dart';
import 'package:moneymate/src/features/dashboard/presentation/spending_pie_chart.dart';
import 'package:moneymate/src/features/dashboard/presentation/welcome_tutorial.dart';
import 'package:moneymate/src/features/expenses/data/expenses_repository_impl.dart';
import 'package:moneymate/src/features/expenses/domain/expense.dart';
import 'package:moneymate/src/features/onboarding/data/couples_repository_impl.dart';
import 'package:moneymate/src/features/onboarding/domain/couple.dart';
import 'package:moneymate/src/features/subscription/data/subscription_repository.dart';
import 'package:moneymate/src/utils/currency_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({
    required this.coupleId,
    super.key,
  });

  final String coupleId;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _showTutorial = false;
  int _selectedIndex = 0;
  Set<String> _notifiedBudgets = {};

  @override
  void initState() {
    super.initState();
    _checkTutorial();
    _loadNotifiedBudgets();
  }

  Future<void> _loadNotifiedBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final month = DateFormat('yyyy-MM').format(DateTime.now());
    final key = 'notified_budgets_$month';
    final saved = prefs.getStringList(key);
    if (saved != null) {
      setState(() => _notifiedBudgets = saved.toSet());
    }
  }

  Future<void> _markBudgetNotified(String category) async {
    _notifiedBudgets.add(category);
    final prefs = await SharedPreferences.getInstance();
    final month = DateFormat('yyyy-MM').format(DateTime.now());
    final key = 'notified_budgets_$month';
    await prefs.setStringList(key, _notifiedBudgets.toList());
  }

  Future<void> _checkTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'tutorial_shown_${widget.coupleId}';
    final alreadyShown = prefs.getBool(key) ?? false;
    if (!alreadyShown && mounted) {
      setState(() => _showTutorial = true);
    }
  }

  Future<void> _completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_shown_${widget.coupleId}', true);
    if (mounted) {
      setState(() => _showTutorial = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final month = DateFormat('yyyy-MM').format(now);
    final monthDisplay = DateFormat('MMMM yyyy').format(now);
    final user = ref.watch(authStateChangesProvider).valueOrNull;
    final currency = user?.currency ?? 'USD';

    return Stack(
      children: [
        Scaffold(
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
                .watchExpenses(coupleId: widget.coupleId, month: month),
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
                    StreamBuilder<Couple?>(
                      stream: ref
                          .read(couplesRepositoryProvider)
                          .watchCouple(widget.coupleId),
                      builder: (context, coupleSnapshot) {
                        final couple = coupleSnapshot.data;
                        if (couple == null ||
                            couple.subscriptionStatus != 'trial') {
                          return const SizedBox.shrink();
                        }

                        final daysLeft = couple.trialEndDate
                            .difference(DateTime.now())
                            .inDays;
                        if (daysLeft > 7) return const SizedBox.shrink();

                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(Sizes.p12),
                          margin: const EdgeInsets.only(bottom: Sizes.p16),
                          decoration: BoxDecoration(
                            color: daysLeft <= 3
                                ? AppColors.expense.withOpacity(0.1)
                                : AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(Sizes.p12),
                            border: Border.all(
                              color: daysLeft <= 3
                                  ? AppColors.expense
                                  : AppColors.warning,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                color: daysLeft <= 3
                                    ? AppColors.expense
                                    : AppColors.warning,
                              ),
                              const SizedBox(width: Sizes.p8),
                              Expanded(
                                child: Text(
                                  daysLeft <= 0
                                      ? 'Your trial has ended. Upgrade to keep Premium features.'
                                      : 'Trial ends in $daysLeft day${daysLeft == 1 ? '' : 's'} — Upgrade to keep Premium',
                                  style:
                                      Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    context.push('/subscription'),
                                child: const Text('Upgrade'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
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
                                  ?.copyWith(
                                      color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: Sizes.p8),
                            Text(
                              CurrencyHelper.formatAmount(
                                  totalSpent, currency),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.expense,
                                  ),
                            ),
                            FutureBuilder<bool>(
                              future: ref.read(isPremiumProvider.future),
                              builder: (context, premiumSnapshot) {
                                if (premiumSnapshot.data == true) {
                                  return const SizedBox.shrink();
                                }
                                return Text(
                                  '${expenses.length}/50 expenses this month',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: expenses.length >= 45
                                            ? AppColors.expense
                                            : AppColors.textSecondary,
                                      ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: Sizes.p16),
                    if (categoryTotals.isNotEmpty)
                      SpendingPieChart(
                        categoryTotals: categoryTotals,
                        currency: currency,
                      ),
                    const SizedBox(height: Sizes.p24),
                    Text(
                      'Budgets',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: Sizes.p12),
                    StreamBuilder<List<Budget>>(
                      stream: ref
                          .read(budgetsRepositoryProvider)
                          .watchBudgets(
                              coupleId: widget.coupleId, month: month),
                      builder: (context, budgetSnapshot) {
                        final budgets = budgetSnapshot.data ?? [];

                        for (final budget in budgets) {
                          final spent =
                              categoryTotals[budget.category] ?? 0;
                          if (spent >= budget.limit &&
                              !_notifiedBudgets.contains(budget.category)) {
                            _markBudgetNotified(budget.category);
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Budget exceeded for ${budget.category}!'),
                                    backgroundColor: AppColors.expense,
                                    duration: const Duration(seconds: 4),
                                  ),
                                );
                              }
                            });
                          }
                        }

                        if (budgets.isEmpty) {
                          return const Card(
                            child: Padding(
                              padding: EdgeInsets.all(Sizes.p24),
                              child: Center(
                                child: Text(
                                    'No budgets set. Tap + to create one.'),
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: budgets.map((budget) {
                            final spent =
                                categoryTotals[budget.category] ?? 0;
                            return BudgetProgressCard(
                              budget: budget,
                              spent: spent,
                              currency: currency,
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
                          context.push('/add-expense/${widget.coupleId}');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.savings),
                        title: const Text('Add Budget'),
                        onTap: () {
                          Navigator.pop(ctx);
                          context.push('/add-budget/${widget.coupleId}');
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
            selectedIndex: _selectedIndex,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(
                  icon: Icon(Icons.list), label: 'Expenses'),
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
                  break;
                case 1:
                  setState(() => _selectedIndex = 1);
                  context.push('/expenses/${widget.coupleId}').then((_) {
                    if (mounted) setState(() => _selectedIndex = 0);
                  });
                case 2:
                  setState(() => _selectedIndex = 2);
                  context.push('/reports/${widget.coupleId}').then((_) {
                    if (mounted) setState(() => _selectedIndex = 0);
                  });
                case 3:
                  setState(() => _selectedIndex = 3);
                  context.push('/settings').then((_) {
                    if (mounted) setState(() => _selectedIndex = 0);
                  });
              }
            },
          ),
        ),
        if (_showTutorial)
          Positioned.fill(
            child: WelcomeTutorial(onComplete: _completeTutorial),
          ),
      ],
    );
  }
}
