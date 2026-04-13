import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneymate/src/constants/app_colors.dart';
import 'package:moneymate/src/constants/app_sizes.dart';
import 'package:moneymate/src/features/auth/data/firebase_auth_repository.dart';
import 'package:moneymate/src/features/expenses/presentation/category_grid.dart';
import 'package:moneymate/src/features/expenses/presentation/expenses_controller.dart';
import 'package:moneymate/src/utils/currency_helper.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({required this.coupleId, super.key});
  final String coupleId;

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  String _amount = '';
  String? _selectedCategory;
  bool _isPrivate = false;

  void _onDigitPressed(String digit) {
    setState(() {
      if (digit == '.' && _amount.contains('.')) return;
      if (digit == '.' && _amount.isEmpty) {
        _amount = '0.';
        return;
      }
      if (_amount.contains('.') && _amount.split('.').last.length >= 2) return;
      _amount += digit;
    });
  }

  void _onBackspace() {
    if (_amount.isNotEmpty) {
      setState(() => _amount = _amount.substring(0, _amount.length - 1));
    }
  }

  Future<void> _onSave() async {
    if (_amount.isEmpty || double.tryParse(_amount) == null) return;
    if (_selectedCategory == null) return;

    final success =
        await ref.read(expensesControllerProvider.notifier).addExpense(
              coupleId: widget.coupleId,
              amount: double.parse(_amount),
              category: _selectedCategory!,
              visibility: _isPrivate ? 'private' : 'shared',
            );

    if (mounted) {
      if (success) {
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to save expense. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(expensesControllerProvider);
    final user = ref.watch(authStateChangesProvider).valueOrNull;
    final currency = user?.currency ?? 'USD';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        actions: [
          IconButton(
            onPressed: () => setState(() => _isPrivate = !_isPrivate),
            icon: Icon(
              _isPrivate ? Icons.lock : Icons.lock_open,
              color: _isPrivate ? AppColors.warning : null,
            ),
            tooltip: _isPrivate ? 'Private' : 'Shared',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Sizes.p32),
            child: Text(
              _amount.isEmpty
                  ? '${CurrencyHelper.symbol(currency)}0'
                  : '${CurrencyHelper.symbol(currency)}$_amount',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.p16),
            child: CategoryGrid(
              selectedCategory: _selectedCategory,
              onCategorySelected: (cat) =>
                  setState(() => _selectedCategory = cat),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(Sizes.p16),
            child: _buildNumberPad(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Sizes.p16,
              0,
              Sizes.p16,
              Sizes.p32,
            ),
            child: ElevatedButton(
              onPressed: state.isLoading ||
                      _amount.isEmpty ||
                      _selectedCategory == null
                  ? null
                  : _onSave,
              child: state.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberPad() {
    const digits = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['.', '0', '<'],
    ];

    return Column(
      children: digits.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((d) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(Sizes.p12),
                    onTap: d == '<' ? _onBackspace : () => _onDigitPressed(d),
                    child: Container(
                      height: 56,
                      alignment: Alignment.center,
                      child: d == '<'
                          ? const Icon(Icons.backspace_outlined)
                          : Text(
                              d,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
