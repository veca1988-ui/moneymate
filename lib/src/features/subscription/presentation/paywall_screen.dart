import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:moneymate/src/constants/app_colors.dart';
import 'package:moneymate/src/constants/app_sizes.dart';
import 'package:moneymate/src/features/subscription/data/subscription_repository.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  Offerings? _offerings;
  bool _isLoading = true;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    try {
      final offerings =
          await ref.read(subscriptionRepositoryProvider).getOfferings();
      setState(() {
        _offerings = offerings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _purchase(Package package) async {
    setState(() => _isPurchasing = true);
    try {
      await ref.read(subscriptionRepositoryProvider).purchasePackage(package);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _isPurchasing = true);
    try {
      await ref.read(subscriptionRepositoryProvider).restorePurchases();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchases restored!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final offering = _offerings?.current;
    final monthly = offering?.monthly;
    final annual = offering?.annual;

    return Scaffold(
      appBar: AppBar(title: const Text('MoneyMate Premium')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(Sizes.p24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.star,
                    size: 64,
                    color: AppColors.warning,
                  ),
                  const SizedBox(height: Sizes.p16),
                  Text(
                    'Unlock Premium',
                    style:
                        Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                  _FeatureRow(text: 'Spending charts & analytics'),
                  _FeatureRow(text: 'Unlimited budget categories'),
                  _FeatureRow(text: 'Export expense reports'),
                  _FeatureRow(text: 'Priority support'),
                  const Spacer(),
                  if (annual != null)
                    _PriceButton(
                      label: 'Annual',
                      price: annual.storeProduct.priceString,
                      subtitle: 'Save 27%',
                      isPrimary: true,
                      onTap: _isPurchasing ? null : () => _purchase(annual),
                    ),
                  const SizedBox(height: Sizes.p12),
                  if (monthly != null)
                    _PriceButton(
                      label: 'Monthly',
                      price: monthly.storeProduct.priceString,
                      isPrimary: false,
                      onTap: _isPurchasing ? null : () => _purchase(monthly),
                    ),
                  const SizedBox(height: Sizes.p16),
                  TextButton(
                    onPressed: _isPurchasing ? null : _restore,
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

class _PriceButton extends StatelessWidget {
  const _PriceButton({
    required this.label,
    required this.price,
    required this.isPrimary,
    required this.onTap,
    this.subtitle,
  });

  final String label;
  final String price;
  final bool isPrimary;
  final VoidCallback? onTap;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return ElevatedButton(
        onPressed: onTap,
        child: Text('$label — $price/year'
            '${subtitle != null ? ' ($subtitle)' : ''}'),
      );
    }
    return OutlinedButton(
      onPressed: onTap,
      child: Text('$label — $price/month'),
    );
  }
}
