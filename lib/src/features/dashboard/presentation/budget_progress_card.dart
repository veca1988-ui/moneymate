import 'package:flutter/material.dart';
import 'package:moneymate/src/constants/app_colors.dart';
import 'package:moneymate/src/constants/app_sizes.dart';
import 'package:moneymate/src/features/budgets/domain/budget.dart';

class BudgetProgressCard extends StatelessWidget {
  const BudgetProgressCard({
    super.key,
    required this.budget,
    required this.spent,
  });

  final Budget budget;
  final double spent;

  @override
  Widget build(BuildContext context) {
    final progress = (spent / budget.limit).clamp(0.0, 1.5);

    final Color progressColor;
    if (progress >= 1.0) {
      progressColor = AppColors.budgetExceeded;
    } else if (progress >= 0.8) {
      progressColor = AppColors.budgetWarning;
    } else {
      progressColor = AppColors.budgetSafe;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: Sizes.p8),
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  budget.category,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  '\$${spent.toStringAsFixed(2)} / '
                  '\$${budget.limit.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: progressColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: Sizes.p8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: progressColor.withOpacity(0.1),
                color: progressColor,
                minHeight: 8,
              ),
            ),
            if (progress >= 1.0)
              Padding(
                padding: const EdgeInsets.only(top: Sizes.p4),
                child: Text(
                  'Over budget by '
                  '\$${(spent - budget.limit).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.budgetExceeded,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
