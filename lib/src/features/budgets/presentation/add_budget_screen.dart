import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:moneymate/src/constants/app_sizes.dart';
import 'package:moneymate/src/features/budgets/data/budgets_repository_impl.dart';
import 'package:moneymate/src/features/budgets/domain/budget.dart';

class AddBudgetScreen extends ConsumerStatefulWidget {
  const AddBudgetScreen({required this.coupleId, super.key});
  final String coupleId;

  @override
  ConsumerState<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends ConsumerState<AddBudgetScreen> {
  final _limitController = TextEditingController();
  String _selectedCategory = 'Groceries';
  bool _isLoading = false;

  static const _categories = [
    'Groceries',
    'Dining',
    'Transport',
    'Shopping',
    'Entertainment',
    'Bills',
    'Health',
    'Other',
  ];

  Future<void> _saveBudget() async {
    final limitValue = double.tryParse(_limitController.text);
    if (limitValue == null || limitValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid budget amount')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final month = DateFormat('yyyy-MM').format(DateTime.now());
      await ref.read(budgetsRepositoryProvider).setBudget(
            coupleId: widget.coupleId,
            budget: Budget(
              id: '',
              category: _selectedCategory,
              limit: limitValue,
              month: month,
            ),
          );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Budget')),
      body: Padding(
        padding: const EdgeInsets.all(Sizes.p24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
            ),
            const SizedBox(height: Sizes.p16),
            TextFormField(
              controller: _limitController,
              decoration: const InputDecoration(
                labelText: 'Budget Limit',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: Sizes.p32),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveBudget,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Budget'),
            ),
          ],
        ),
      ),
    );
  }
}
