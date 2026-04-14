import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:moneymate/src/constants/app_colors.dart';
import 'package:moneymate/src/constants/app_sizes.dart';
import 'package:moneymate/src/features/auth/data/firebase_auth_repository.dart';
import 'package:moneymate/src/features/expenses/data/expenses_repository_impl.dart';
import 'package:moneymate/src/features/expenses/domain/expense.dart';
import 'package:moneymate/src/features/subscription/data/subscription_repository.dart';
import 'package:moneymate/src/utils/currency_helper.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({
    required this.coupleId,
    super.key,
  });

  final String coupleId;

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _selectedMonth.year == now.year && _selectedMonth.month == now.month;
  }

  String get _monthKey => DateFormat('yyyy-MM').format(_selectedMonth);

  void _previousMonth() async {
    final isPremium = await ref.read(isPremiumProvider.future);
    if (!isPremium) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Premium Feature'),
            content: const Text('View past months with MoneyMate Premium.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.push('/subscription');
                },
                child: const Text('Upgrade'),
              ),
            ],
          ),
        );
      }
      return;
    }
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    if (!_isCurrentMonth) {
      setState(() {
        _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateChangesProvider).valueOrNull;
    final currency = user?.currency ?? 'USD';
    final monthDisplay = DateFormat('MMMM yyyy').format(_selectedMonth);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: Column(
        children: [
          _MonthSelector(
            monthDisplay: monthDisplay,
            isCurrentMonth: _isCurrentMonth,
            onPrevious: _previousMonth,
            onNext: _nextMonth,
          ),
          Expanded(
            child: StreamBuilder<List<Expense>>(
              stream: ref
                  .read(expensesRepositoryProvider)
                  .watchExpenses(coupleId: widget.coupleId, month: _monthKey),
              builder: (context, snapshot) {
                final expenses = snapshot.data ?? [];

                if (expenses.isEmpty) {
                  return const Center(
                    child: Text('No expenses this month'),
                  );
                }

                final totalSpent =
                    expenses.fold<double>(0, (sum, e) => sum + e.amount);

                final categoryTotals = <String, double>{};
                for (final expense in expenses) {
                  categoryTotals[expense.category] =
                      (categoryTotals[expense.category] ?? 0) + expense.amount;
                }

                final sortedCategories = categoryTotals.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(Sizes.p16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TotalSpentCard(
                        totalSpent: totalSpent,
                        currency: currency,
                      ),
                      const SizedBox(height: Sizes.p24),
                      Text(
                        'By Category',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: Sizes.p12),
                      ...sortedCategories.asMap().entries.map((entry) {
                        final index = entry.key;
                        final category = entry.value.key;
                        final amount = entry.value.value;
                        final percentage =
                            totalSpent > 0 ? amount / totalSpent : 0.0;
                        final color = AppColors.categoryColors[
                            index % AppColors.categoryColors.length];

                        return _CategoryRow(
                          category: category,
                          amount: amount,
                          percentage: percentage,
                          color: color,
                          currency: currency,
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.monthDisplay,
    required this.isCurrentMonth,
    required this.onPrevious,
    required this.onNext,
  });

  final String monthDisplay;
  final bool isCurrentMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.p8,
        vertical: Sizes.p8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrevious,
          ),
          SizedBox(
            width: 160,
            child: Text(
              monthDisplay,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: isCurrentMonth
                  ? Theme.of(context).disabledColor
                  : null,
            ),
            onPressed: isCurrentMonth ? null : onNext,
          ),
        ],
      ),
    );
  }
}

class _TotalSpentCard extends StatelessWidget {
  const _TotalSpentCard({
    required this.totalSpent,
    required this.currency,
  });

  final double totalSpent;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Card(
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
              CurrencyHelper.formatAmount(totalSpent, currency),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.expense,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.color,
    required this.currency,
  });

  final String category;
  final double amount;
  final double percentage;
  final Color color;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final percentageText = '${(percentage * 100).toStringAsFixed(1)}%';

    return Padding(
      padding: const EdgeInsets.only(bottom: Sizes.p12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                '${CurrencyHelper.formatAmount(amount, currency)} ($percentageText)',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: Sizes.p4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
