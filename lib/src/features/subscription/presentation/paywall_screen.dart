import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneymate/src/constants/app_colors.dart';
import 'package:moneymate/src/constants/app_sizes.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('MoneyMate Premium')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Sizes.p24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.star, size: 64, color: AppColors.warning),
            const SizedBox(height: Sizes.p16),
            Text(
              'Unlock Premium',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Sizes.p8),
            Text(
              'Get the most out of MoneyMate',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Sizes.p32),
            const _FeatureRow(text: 'Unlimited expenses (free: 50/month)'),
            const _FeatureRow(text: 'Full Reports history (free: current month only)'),
            const _FeatureRow(text: 'CSV export (coming soon)'),
            const _FeatureRow(text: 'Budget alerts (coming soon)'),
            const _FeatureRow(text: 'Priority support'),
            const SizedBox(height: Sizes.p24),
            // Free vs Premium comparison
            Card(
              child: Padding(
                padding: const EdgeInsets.all(Sizes.p16),
                child: Column(
                  children: [
                    // Column headers
                    Row(
                      children: [
                        const Expanded(flex: 2, child: SizedBox()),
                        Expanded(
                          child: Text(
                            'Free',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Premium',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Sizes.p8),
                    _ComparisonRow(feature: 'Expenses', free: '50/month', premium: 'Unlimited'),
                    _ComparisonRow(feature: 'Reports', free: 'Current month', premium: 'All history'),
                    _ComparisonRow(feature: 'Categories', free: 'All 8', premium: 'All + Custom'),
                    _ComparisonRow(feature: 'CSV Export', free: '—', premium: '✓'),
                    _ComparisonRow(feature: 'Budget Alerts', free: '—', premium: '✓'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Sizes.p24),
            Text(
              'All premium features are free during the beta period.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Sizes.p16),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All features are free during beta! Enjoy!'),
                  ),
                );
              },
              child: const Text('Start Free Trial'),
            ),
            const SizedBox(height: Sizes.p12),
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All features are free during beta! Enjoy!'),
                  ),
                );
              },
              child: const Text('Notify me when Premium launches'),
            ),
            const SizedBox(height: Sizes.p16),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Restore Purchases'),
            ),
            const SizedBox(height: Sizes.p16),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.p4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.income, size: 20),
          const SizedBox(width: Sizes.p12),
          Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({required this.feature, required this.free, required this.premium});
  final String feature;
  final String free;
  final String premium;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(feature)),
          Expanded(
            child: Text(
              free,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              premium,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
