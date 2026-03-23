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
      body: Padding(
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
            const _FeatureRow(text: 'Spending charts & analytics'),
            const _FeatureRow(text: 'Unlimited budget categories'),
            const _FeatureRow(text: 'Export expense reports'),
            const _FeatureRow(text: 'Priority support'),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Subscriptions available after setup'),
                  ),
                );
              },
              child: const Text(r'Annual — $34.99/year (Save 27%)'),
            ),
            const SizedBox(height: Sizes.p12),
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Subscriptions available after setup'),
                  ),
                );
              },
              child: const Text(r'Monthly — $3.99/month'),
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
