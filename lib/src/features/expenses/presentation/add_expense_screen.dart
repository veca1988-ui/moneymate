import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:moneymate/src/constants/app_colors.dart';
import 'package:moneymate/src/constants/app_sizes.dart';
import 'package:moneymate/src/features/auth/data/firebase_auth_repository.dart';
import 'package:moneymate/src/features/expenses/data/expenses_repository_impl.dart';
import 'package:moneymate/src/features/expenses/domain/expense.dart';
import 'package:moneymate/src/features/expenses/presentation/category_grid.dart';
import 'package:moneymate/src/features/expenses/presentation/expenses_controller.dart';
import 'package:moneymate/src/features/subscription/data/subscription_repository.dart';
import 'package:moneymate/src/utils/currency_helper.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({required this.coupleId, this.expense, super.key});
  final String coupleId;
  final Expense? expense;

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  String _amount = '';
  String? _selectedCategory;
  bool _isPrivate = false;
  DateTime _selectedDate = DateTime.now();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    if (e != null) {
      _amount = e.amount.toString();
      _selectedCategory = e.category;
      _isPrivate = e.visibility == 'private';
      _selectedDate = e.date;
      _noteController.text = e.note;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 1, now.month, now.day),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

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
    if (_amount.isEmpty || _amount == '0' || double.tryParse(_amount) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    final isPremium = await ref.read(isPremiumProvider.future);
    if (!isPremium) {
      // Count expenses for current month
      final month = DateFormat('yyyy-MM').format(DateTime.now());
      final expenses = await ref
          .read(expensesRepositoryProvider)
          .watchExpenses(coupleId: widget.coupleId, month: month)
          .first;
      if (expenses.length >= 50) {
        if (mounted) {
          context.push('/subscription');
        }
        return;
      }
    }

    final controller = ref.read(expensesControllerProvider.notifier);
    final bool success;

    if (widget.expense != null) {
      final updated = widget.expense!.copyWith(
        amount: double.parse(_amount),
        category: _selectedCategory!,
        visibility: _isPrivate ? 'private' : 'shared',
        date: _selectedDate,
        note: _noteController.text.trim(),
      );
      success = await controller.updateExpense(
        coupleId: widget.coupleId,
        expense: updated,
      );
    } else {
      success = await controller.addExpense(
        coupleId: widget.coupleId,
        amount: double.parse(_amount),
        category: _selectedCategory!,
        visibility: _isPrivate ? 'private' : 'shared',
        date: _selectedDate,
        note: _noteController.text.trim(),
      );
    }

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
        title: Text(widget.expense != null ? 'Edit Expense' : 'Add Expense'),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: Sizes.p32),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Sizes.p24),
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
              const SizedBox(height: Sizes.p16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Sizes.p16),
                child: InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(Sizes.p12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Sizes.p8,
                      vertical: Sizes.p12,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined),
                        const SizedBox(width: Sizes.p8),
                        Text(
                          DateFormat('EEE, MMM d, yyyy').format(_selectedDate),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Sizes.p16,
                  vertical: Sizes.p8,
                ),
                child: TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    prefixIcon: Icon(Icons.note_outlined),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(Sizes.p16),
                child: _buildNumberPad(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Sizes.p16),
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
        ),
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
