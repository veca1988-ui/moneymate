import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneymate/src/constants/app_colors.dart';
import 'package:moneymate/src/constants/app_sizes.dart';
import 'package:moneymate/src/features/auth/data/firebase_auth_repository.dart';
import 'package:moneymate/src/features/onboarding/data/couples_repository_impl.dart';

class PrivacySettingsScreen extends ConsumerStatefulWidget {
  const PrivacySettingsScreen({required this.coupleId, super.key});
  final String coupleId;

  @override
  ConsumerState<PrivacySettingsScreen> createState() =>
      _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends ConsumerState<PrivacySettingsScreen> {
  static const _categories = [
    'Groceries',
    'Dining',
    'Transport',
    'Bills',
    'Entertainment',
    'Shopping',
    'Health',
    'Other',
  ];

  static const _visibilityOptions = ['all', 'total', 'private'];

  Map<String, String> _settings = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final userId = ref.read(firebaseAuthRepositoryProvider).currentUserId!;
    final settings =
        await ref.read(couplesRepositoryProvider).getPartnerPrivacySettings(
              coupleId: widget.coupleId,
              partnerUserId: userId,
            );
    setState(() {
      _settings = Map.from(settings);
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final userId = ref.read(firebaseAuthRepositoryProvider).currentUserId!;
    await ref.read(couplesRepositoryProvider).updatePrivacySettings(
          coupleId: widget.coupleId,
          userId: userId,
          settings: _settings,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Privacy settings saved')),
      );
    }
  }

  String _visibilityLabel(String value) {
    return switch (value) {
      'all' => 'Share All',
      'total' => 'Total Only',
      'private' => 'Private',
      _ => value,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Controls'),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text('Save'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(Sizes.p16),
              children: [
                Text(
                  'Control what your partner can see for each category.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: Sizes.p8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Sizes.p8,
                      vertical: Sizes.p4,
                    ),
                    child: Column(
                      children: [
                        for (final category in _categories)
                          _buildCategoryRow(context, category),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Sizes.p24),
                _buildLegend(context),
              ],
            ),
    );
  }

  Widget _buildCategoryRow(BuildContext context, String category) {
    final currentValue = _settings[category] ?? 'all';

    return ListTile(
      title: Text(category),
      trailing: DropdownButton<String>(
        value: currentValue,
        underline: const SizedBox.shrink(),
        items: _visibilityOptions.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(_visibilityLabel(option)),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => _settings[category] = value);
          }
        },
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Card(
      color: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Visibility Levels',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: Sizes.p8),
            _legendItem(
              context,
              'Share All',
              'Partner sees every transaction',
            ),
            _legendItem(
              context,
              'Total Only',
              'Partner sees category total, not individual items',
            ),
            _legendItem(
              context,
              'Private',
              'Partner cannot see anything in this category',
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.p4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall,
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
