# Faza 1: Core Features Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete the 6 core features needed before monetization: currency display, edit/delete expenses, date picker, note field + user name, reports tab, and unlink partner.

**Architecture:** All changes follow the existing feature-first structure with Riverpod providers, Freezed models, and GoRouter. New utility files are added for currency formatting. Reports gets a new feature directory. All other changes modify existing files.

**Tech Stack:** Flutter/Dart, Riverpod 2.x, Freezed, GoRouter, Firebase Firestore, fl_chart, intl

---

### Task 1: Currency Helper

**Files:**
- Create: `lib/src/utils/currency_helper.dart`
- Test: `test/src/utils/currency_helper_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/src/utils/currency_helper_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/src/utils/currency_helper.dart';

void main() {
  group('CurrencyHelper', () {
    test('formatAmount returns correct symbol for USD', () {
      expect(CurrencyHelper.formatAmount(42.5, 'USD'), '\$42.50');
    });

    test('formatAmount returns correct symbol for EUR', () {
      expect(CurrencyHelper.formatAmount(42.5, 'EUR'), '€42.50');
    });

    test('formatAmount returns correct symbol for GBP', () {
      expect(CurrencyHelper.formatAmount(42.5, 'GBP'), '£42.50');
    });

    test('formatAmount returns correct symbol for RSD', () {
      expect(CurrencyHelper.formatAmount(42.5, 'RSD'), '43 RSD');
    });

    test('formatAmount returns correct symbol for CAD', () {
      expect(CurrencyHelper.formatAmount(42.5, 'CAD'), 'C\$42.50');
    });

    test('formatAmount returns correct symbol for AUD', () {
      expect(CurrencyHelper.formatAmount(42.5, 'AUD'), 'A\$42.50');
    });

    test('symbol returns just the symbol', () {
      expect(CurrencyHelper.symbol('USD'), '\$');
      expect(CurrencyHelper.symbol('EUR'), '€');
      expect(CurrencyHelper.symbol('RSD'), 'RSD');
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `fvm flutter test test/src/utils/currency_helper_test.dart`
Expected: FAIL — `currency_helper.dart` does not exist

- [ ] **Step 3: Write the implementation**

```dart
// lib/src/utils/currency_helper.dart
class CurrencyHelper {
  static const _symbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'RSD': 'RSD',
    'CAD': 'C\$',
    'AUD': 'A\$',
  };

  static const _noDecimals = {'RSD'};

  static String symbol(String currencyCode) {
    return _symbols[currencyCode] ?? currencyCode;
  }

  static String formatAmount(double amount, String currencyCode) {
    final sym = symbol(currencyCode);
    if (_noDecimals.contains(currencyCode)) {
      return '${amount.round()} $sym';
    }
    return '$sym${amount.toStringAsFixed(2)}';
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `fvm flutter test test/src/utils/currency_helper_test.dart`
Expected: All 7 tests PASS

- [ ] **Step 5: Commit**

```bash
git add lib/src/utils/currency_helper.dart test/src/utils/currency_helper_test.dart
git commit -m "feat: add CurrencyHelper for multi-currency formatting"
```

---

### Task 2: Apply Currency Helper to Dashboard

**Files:**
- Modify: `lib/src/features/dashboard/presentation/dashboard_screen.dart`
- Modify: `lib/src/features/dashboard/presentation/budget_progress_card.dart`
- Modify: `lib/src/features/dashboard/presentation/spending_pie_chart.dart`

- [ ] **Step 1: Update DashboardScreen to read user currency and pass it down**

In `dashboard_screen.dart`, add import and read currency from auth state:

```dart
// Add at top:
import 'package:moneymate/src/features/auth/data/firebase_auth_repository.dart';
import 'package:moneymate/src/utils/currency_helper.dart';

// Inside build(), after final monthDisplay line, add:
final user = ref.watch(authStateChangesProvider).valueOrNull;
final currency = user?.currency ?? 'USD';
```

Replace the Total Spent text (the line with `'\$${totalSpent.toStringAsFixed(2)}'`):

```dart
CurrencyHelper.formatAmount(totalSpent, currency),
```

Pass `currency` to `SpendingPieChart`:

```dart
SpendingPieChart(categoryTotals: categoryTotals, currency: currency),
```

Pass `currency` to `BudgetProgressCard`:

```dart
BudgetProgressCard(budget: budget, spent: spent, currency: currency),
```

- [ ] **Step 2: Update SpendingPieChart to accept and use currency**

In `spending_pie_chart.dart`, add the currency parameter:

```dart
import 'package:moneymate/src/utils/currency_helper.dart';

class SpendingPieChart extends StatelessWidget {
  const SpendingPieChart({required this.categoryTotals, required this.currency, super.key});
  final Map<String, double> categoryTotals;
  final String currency;
```

Replace the legend text that shows `'\$${value.toInt()}'` with:

```dart
'${entry.key}: ${CurrencyHelper.formatAmount(entry.value, currency)}'
```

- [ ] **Step 3: Update BudgetProgressCard to accept and use currency**

In `budget_progress_card.dart`, add currency parameter:

```dart
import 'package:moneymate/src/utils/currency_helper.dart';

class BudgetProgressCard extends StatelessWidget {
  const BudgetProgressCard({
    required this.budget,
    required this.spent,
    required this.currency,
    super.key,
  });

  final Budget budget;
  final double spent;
  final String currency;
```

Replace all hardcoded `$` amount strings with `CurrencyHelper.formatAmount(...)`:
- `'\$${spent.toStringAsFixed(0)}'` → `CurrencyHelper.formatAmount(spent, currency)`
- `'\$${budget.limit.toStringAsFixed(0)}'` → `CurrencyHelper.formatAmount(budget.limit, currency)`
- The "Over budget by" text similarly

- [ ] **Step 4: Run the app and verify currency displays correctly**

Run: `fvm flutter test`
Expected: All existing tests pass

- [ ] **Step 5: Commit**

```bash
git add lib/src/features/dashboard/presentation/dashboard_screen.dart \
  lib/src/features/dashboard/presentation/budget_progress_card.dart \
  lib/src/features/dashboard/presentation/spending_pie_chart.dart
git commit -m "feat: apply currency formatting to dashboard, pie chart, and budget cards"
```

---

### Task 3: Apply Currency Helper to Expense Screens

**Files:**
- Modify: `lib/src/features/expenses/presentation/expenses_list_screen.dart`
- Modify: `lib/src/features/expenses/presentation/add_expense_screen.dart`

- [ ] **Step 1: Update ExpensesListScreen to use currency**

In `expenses_list_screen.dart`, add imports and read currency:

```dart
import 'package:moneymate/src/features/auth/data/firebase_auth_repository.dart';
import 'package:moneymate/src/utils/currency_helper.dart';

// Inside build(), before the StreamBuilder:
final user = ref.watch(authStateChangesProvider).valueOrNull;
final currency = user?.currency ?? 'USD';
```

Replace all `'\$${...}'` patterns with `CurrencyHelper.formatAmount(...)`:
- Day total: `CurrencyHelper.formatAmount(dayTotal, currency)`
- Individual expense amount in `_ExpenseListTile`: `CurrencyHelper.formatAmount(expense.amount, currency)`

- [ ] **Step 2: Update AddExpenseScreen amount display**

In `add_expense_screen.dart`, add imports and read currency:

```dart
import 'package:moneymate/src/features/auth/data/firebase_auth_repository.dart';
import 'package:moneymate/src/utils/currency_helper.dart';

// Inside build():
final user = ref.watch(authStateChangesProvider).valueOrNull;
final currency = user?.currency ?? 'USD';
```

Replace the amount display text that shows `'\$$_amount'` with:

```dart
'${CurrencyHelper.symbol(currency)}$_amount'
```

- [ ] **Step 3: Run tests**

Run: `fvm flutter test`
Expected: All tests pass

- [ ] **Step 4: Commit**

```bash
git add lib/src/features/expenses/presentation/expenses_list_screen.dart \
  lib/src/features/expenses/presentation/add_expense_screen.dart
git commit -m "feat: apply currency formatting to expense list and add expense screens"
```

---

### Task 4: Date Picker in AddExpenseScreen

**Files:**
- Modify: `lib/src/features/expenses/presentation/add_expense_screen.dart`

- [ ] **Step 1: Add date state and date picker**

In `_AddExpenseScreenState`, add a date field:

```dart
DateTime _selectedDate = DateTime.now();
```

Add a method to show the date picker:

```dart
Future<void> _pickDate() async {
  final picked = await showDatePicker(
    context: context,
    initialDate: _selectedDate,
    firstDate: DateTime.now().subtract(const Duration(days: 365)),
    lastDate: DateTime.now(),
  );
  if (picked != null) {
    setState(() => _selectedDate = picked);
  }
}
```

- [ ] **Step 2: Add date row to the UI**

Add a tappable date row above the number pad (before `_buildNumberPad()`):

```dart
GestureDetector(
  onTap: _pickDate,
  child: Padding(
    padding: const EdgeInsets.symmetric(vertical: Sizes.p8, horizontal: Sizes.p16),
    child: Row(
      children: [
        const Icon(Icons.calendar_today, size: 20),
        const SizedBox(width: Sizes.p8),
        Text(
          DateFormat('EEE, MMM d, yyyy').format(_selectedDate),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const Spacer(),
        const Icon(Icons.chevron_right),
      ],
    ),
  ),
),
```

Add import at top: `import 'package:intl/intl.dart';`

- [ ] **Step 3: Pass selected date to addExpense**

In the `_onSave` method, change the `addExpense` call to pass the date:

```dart
final success = await ref.read(expensesControllerProvider.notifier).addExpense(
  coupleId: widget.coupleId,
  amount: amount,
  category: _selectedCategory!,
  visibility: _isPrivate ? 'private' : 'shared',
  date: _selectedDate,
);
```

- [ ] **Step 4: Run tests and verify**

Run: `fvm flutter test`
Expected: All tests pass

- [ ] **Step 5: Commit**

```bash
git add lib/src/features/expenses/presentation/add_expense_screen.dart
git commit -m "feat: add date picker to AddExpenseScreen"
```

---

### Task 5: Note Field in AddExpenseScreen

**Files:**
- Modify: `lib/src/features/expenses/presentation/add_expense_screen.dart`

- [ ] **Step 1: Add note controller and field**

In `_AddExpenseScreenState`, add:

```dart
final _noteController = TextEditingController();
```

In `dispose()`, add:

```dart
_noteController.dispose();
```

- [ ] **Step 2: Add note text field to UI**

Add below the date row, before the number pad:

```dart
Padding(
  padding: const EdgeInsets.symmetric(horizontal: Sizes.p16),
  child: TextField(
    controller: _noteController,
    decoration: const InputDecoration(
      labelText: 'Note (optional)',
      prefixIcon: Icon(Icons.note_outlined),
      border: OutlineInputBorder(),
    ),
    maxLines: 1,
  ),
),
const SizedBox(height: Sizes.p8),
```

- [ ] **Step 3: Pass note to addExpense**

In `_onSave`, add `note` parameter:

```dart
final success = await ref.read(expensesControllerProvider.notifier).addExpense(
  coupleId: widget.coupleId,
  amount: amount,
  category: _selectedCategory!,
  visibility: _isPrivate ? 'private' : 'shared',
  date: _selectedDate,
  note: _noteController.text.trim(),
);
```

- [ ] **Step 4: Run tests**

Run: `fvm flutter test`
Expected: All tests pass

- [ ] **Step 5: Commit**

```bash
git add lib/src/features/expenses/presentation/add_expense_screen.dart
git commit -m "feat: add note field to AddExpenseScreen"
```

---

### Task 6: Add userName to Expense Documents

**Files:**
- Modify: `lib/src/features/expenses/presentation/expenses_controller.dart`

- [ ] **Step 1: Embed userName when creating expense**

In `expenses_controller.dart`, read the user name from auth state and pass it to the expense:

```dart
import 'package:moneymate/src/features/auth/data/firebase_auth_repository.dart';
import 'package:moneymate/src/features/expenses/data/expenses_repository_impl.dart';
import 'package:moneymate/src/features/expenses/domain/expense.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'expenses_controller.g.dart';

@riverpod
class ExpensesController extends _$ExpensesController {
  @override
  FutureOr<void> build() {}

  Future<bool> addExpense({
    required String coupleId,
    required double amount,
    required String category,
    required String visibility,
    String note = '',
    DateTime? date,
  }) async {
    final repo = ref.read(expensesRepositoryProvider);
    final authRepo = ref.read(firebaseAuthRepositoryProvider);
    final userId = authRepo.currentUserId!;
    final user = ref.read(authStateChangesProvider).valueOrNull;
    final userName = user?.name ?? '';

    final expense = Expense(
      id: '',
      amount: amount,
      category: category,
      date: date ?? DateTime.now(),
      userId: userId,
      visibility: visibility,
      createdAt: DateTime.now(),
      note: note,
      userName: userName,
    );

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => repo.addExpense(coupleId: coupleId, expense: expense),
    );
    return !state.hasError;
  }
}
```

- [ ] **Step 2: Add userName field to Expense model**

In `lib/src/features/expenses/domain/expense.dart`, add `userName` field:

```dart
@freezed
class Budget with _$Budget {
  const factory Expense({
    required String id,
    required double amount,
    required String category,
    required DateTime date,
    required String userId,
    required String visibility,
    required DateTime createdAt,
    @Default('') String note,
    @Default('') String userName,
  }) = _Expense;
```

- [ ] **Step 3: Regenerate freezed code**

Run: `fvm flutter pub run build_runner build --delete-conflicting-outputs`
Expected: Code generation completes without errors

- [ ] **Step 4: Run tests and fix any failures**

Run: `fvm flutter test`
Expected: Tests may need `userName` added to test expense constructors — fix if needed

- [ ] **Step 5: Commit**

```bash
git add lib/src/features/expenses/domain/expense.dart \
  lib/src/features/expenses/domain/expense.freezed.dart \
  lib/src/features/expenses/domain/expense.g.dart \
  lib/src/features/expenses/presentation/expenses_controller.dart
git commit -m "feat: embed userName in expense documents"
```

---

### Task 7: Show Note and User Name in Expense List

**Files:**
- Modify: `lib/src/features/expenses/presentation/expenses_list_screen.dart`

- [ ] **Step 1: Update _ExpenseListTile to show note and userName**

In the `_ExpenseListTile` widget, update the build method to show additional info:

```dart
class _ExpenseListTile extends StatelessWidget {
  const _ExpenseListTile({required this.expense, required this.currency});
  final Expense expense;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        _categoryIcon(expense.category),
        color: AppColors.primary,
      ),
      title: Text(expense.category),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (expense.userName.isNotEmpty)
            Text(
              expense.userName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          if (expense.note.isNotEmpty)
            Text(
              expense.note,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            CurrencyHelper.formatAmount(expense.amount, currency),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (expense.visibility == 'private') ...[
            const SizedBox(width: 4),
            const Icon(Icons.lock, size: 14, color: AppColors.textSecondary),
          ],
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Groceries': return Icons.shopping_cart;
      case 'Dining': return Icons.restaurant;
      case 'Transport': return Icons.directions_car;
      case 'Bills': return Icons.receipt;
      case 'Entertainment': return Icons.movie;
      case 'Shopping': return Icons.shopping_bag;
      case 'Health': return Icons.medical_services;
      default: return Icons.category;
    }
  }
}
```

Pass `currency` when creating `_ExpenseListTile`:

```dart
_ExpenseListTile(expense: expense, currency: currency),
```

- [ ] **Step 2: Run tests**

Run: `fvm flutter test`
Expected: All tests pass

- [ ] **Step 3: Commit**

```bash
git add lib/src/features/expenses/presentation/expenses_list_screen.dart
git commit -m "feat: show note and userName in expense list tiles"
```

---

### Task 8: Edit/Delete Expenses

**Files:**
- Modify: `lib/src/features/expenses/presentation/expenses_list_screen.dart`
- Modify: `lib/src/features/expenses/presentation/add_expense_screen.dart`
- Modify: `lib/src/features/expenses/presentation/expenses_controller.dart`
- Modify: `lib/src/routing/app_router.dart`

- [ ] **Step 1: Add updateExpense and deleteExpense to controller**

In `expenses_controller.dart`, add two methods after `addExpense`:

```dart
Future<bool> updateExpense({
  required String coupleId,
  required Expense expense,
}) async {
  final repo = ref.read(expensesRepositoryProvider);
  state = const AsyncLoading();
  state = await AsyncValue.guard(
    () => repo.updateExpense(coupleId: coupleId, expense: expense),
  );
  return !state.hasError;
}

Future<bool> deleteExpense({
  required String coupleId,
  required String expenseId,
}) async {
  final repo = ref.read(expensesRepositoryProvider);
  state = const AsyncLoading();
  state = await AsyncValue.guard(
    () => repo.deleteExpense(coupleId: coupleId, expenseId: expenseId),
  );
  return !state.hasError;
}
```

- [ ] **Step 2: Update AddExpenseScreen to support edit mode**

Change the constructor to accept an optional expense:

```dart
class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({required this.coupleId, this.expense, super.key});
  final String coupleId;
  final Expense? expense;
```

In `initState`, pre-populate fields if editing:

```dart
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
```

Update `_onSave` to handle edit vs create:

```dart
Future<void> _onSave() async {
  if (_selectedCategory == null || _amount == '0') return;
  final amount = double.tryParse(_amount);
  if (amount == null || amount <= 0) return;

  bool success;
  if (widget.expense != null) {
    success = await ref.read(expensesControllerProvider.notifier).updateExpense(
      coupleId: widget.coupleId,
      expense: widget.expense!.copyWith(
        amount: amount,
        category: _selectedCategory!,
        visibility: _isPrivate ? 'private' : 'shared',
        date: _selectedDate,
        note: _noteController.text.trim(),
      ),
    );
  } else {
    success = await ref.read(expensesControllerProvider.notifier).addExpense(
      coupleId: widget.coupleId,
      amount: amount,
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
        const SnackBar(content: Text('Failed to save expense. Please try again.')),
      );
    }
  }
}
```

Update the AppBar title:

```dart
appBar: AppBar(
  title: Text(widget.expense != null ? 'Edit Expense' : 'Add Expense'),
```

- [ ] **Step 3: Add edit route**

In `app_router.dart`, add a route for editing (after the add-expense route):

```dart
GoRoute(
  path: '/edit-expense/:coupleId',
  builder: (context, state) => AddExpenseScreen(
    coupleId: state.pathParameters['coupleId']!,
    expense: state.extra as Expense?,
  ),
),
```

Add import: `import 'package:moneymate/src/features/expenses/domain/expense.dart';`

- [ ] **Step 4: Add swipe-to-delete and tap-to-edit in ExpensesListScreen**

Wrap `_ExpenseListTile` with `Dismissible` and `GestureDetector`:

```dart
Dismissible(
  key: Key(expense.id),
  direction: DismissDirection.endToStart,
  background: Container(
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: Sizes.p16),
    color: AppColors.expense,
    child: const Icon(Icons.delete, color: Colors.white),
  ),
  confirmDismiss: (direction) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  },
  onDismissed: (_) {
    ref.read(expensesControllerProvider.notifier).deleteExpense(
      coupleId: coupleId,
      expenseId: expense.id,
    );
  },
  child: GestureDetector(
    onTap: () => context.push('/edit-expense/$coupleId', extra: expense),
    child: _ExpenseListTile(expense: expense, currency: currency),
  ),
),
```

Add imports at top of file:

```dart
import 'package:moneymate/src/features/expenses/presentation/expenses_controller.dart';
```

- [ ] **Step 5: Run tests**

Run: `fvm flutter test`
Expected: All tests pass

- [ ] **Step 6: Commit**

```bash
git add lib/src/features/expenses/presentation/expenses_list_screen.dart \
  lib/src/features/expenses/presentation/add_expense_screen.dart \
  lib/src/features/expenses/presentation/expenses_controller.dart \
  lib/src/routing/app_router.dart
git commit -m "feat: add edit/delete expenses with swipe and tap interactions"
```

---

### Task 9: Reports Screen

**Files:**
- Create: `lib/src/features/reports/presentation/reports_screen.dart`
- Modify: `lib/src/routing/app_router.dart`
- Modify: `lib/src/features/dashboard/presentation/dashboard_screen.dart`

- [ ] **Step 1: Create ReportsScreen**

```dart
// lib/src/features/reports/presentation/reports_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:moneymate/src/constants/app_colors.dart';
import 'package:moneymate/src/constants/app_sizes.dart';
import 'package:moneymate/src/features/auth/data/firebase_auth_repository.dart';
import 'package:moneymate/src/features/expenses/data/expenses_repository_impl.dart';
import 'package:moneymate/src/features/expenses/domain/expense.dart';
import 'package:moneymate/src/utils/currency_helper.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({required this.coupleId, super.key});
  final String coupleId;

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    final next = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    if (next.isBefore(DateTime(now.year, now.month + 1))) {
      setState(() => _selectedMonth = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateChangesProvider).valueOrNull;
    final currency = user?.currency ?? 'USD';
    final month = DateFormat('yyyy-MM').format(_selectedMonth);
    final monthDisplay = DateFormat('MMMM yyyy').format(_selectedMonth);

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Column(
        children: [
          // Month selector
          Padding(
            padding: const EdgeInsets.all(Sizes.p16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _previousMonth,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  monthDisplay,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  onPressed: _nextMonth,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          // Category breakdown
          Expanded(
            child: StreamBuilder<List<Expense>>(
              stream: ref
                  .read(expensesRepositoryProvider)
                  .watchExpenses(coupleId: widget.coupleId, month: month),
              builder: (context, snapshot) {
                final expenses = snapshot.data ?? [];

                if (expenses.isEmpty) {
                  return const Center(child: Text('No expenses this month'));
                }

                final totalSpent = expenses.fold<double>(0, (sum, e) => sum + e.amount);
                final categoryTotals = <String, double>{};
                for (final e in expenses) {
                  categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
                }

                final sortedCategories = categoryTotals.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                return ListView(
                  padding: const EdgeInsets.all(Sizes.p16),
                  children: [
                    // Total card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(Sizes.p24),
                        child: Column(
                          children: [
                            Text(
                              'Total Spent',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                            const SizedBox(height: Sizes.p8),
                            Text(
                              CurrencyHelper.formatAmount(totalSpent, currency),
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.expense,
                                  ),
                            ),
                            const SizedBox(height: Sizes.p4),
                            Text(
                              '${expenses.length} expenses',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: Sizes.p24),
                    Text(
                      'By Category',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: Sizes.p12),
                    // Category list
                    ...sortedCategories.map((entry) {
                      final percent = (entry.value / totalSpent * 100).round();
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: Sizes.p4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(entry.key),
                                Text(
                                  '${CurrencyHelper.formatAmount(entry.value, currency)} ($percent%)',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: Sizes.p4),
                            LinearProgressIndicator(
                              value: entry.value / totalSpent,
                              backgroundColor: Colors.grey.shade200,
                              color: AppColors.primary,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Add route for Reports**

In `app_router.dart`, add the route and import:

```dart
import 'package:moneymate/src/features/reports/presentation/reports_screen.dart';
```

Add route after the expenses route:

```dart
GoRoute(
  path: '/reports/:coupleId',
  builder: (context, state) => ReportsScreen(
    coupleId: state.pathParameters['coupleId']!,
  ),
),
```

- [ ] **Step 3: Wire up Reports tab in DashboardScreen navigation**

In `dashboard_screen.dart`, update the `onDestinationSelected` switch case 2:

```dart
case 2:
  context.push('/reports/$coupleId');
```

- [ ] **Step 4: Run tests**

Run: `fvm flutter test`
Expected: All tests pass

- [ ] **Step 5: Commit**

```bash
git add lib/src/features/reports/presentation/reports_screen.dart \
  lib/src/routing/app_router.dart \
  lib/src/features/dashboard/presentation/dashboard_screen.dart
git commit -m "feat: add Reports screen with category breakdown and month navigation"
```

---

### Task 10: Unlink Partner

**Files:**
- Modify: `lib/src/features/settings/presentation/settings_screen.dart`

- [ ] **Step 1: Update SettingsScreen to be ConsumerStatefulWidget with unlink logic**

Change the SettingsScreen to read `coupleId` and `user`, and conditionally show Unlink Partner:

Add imports:

```dart
import 'package:moneymate/src/features/onboarding/data/couples_repository_impl.dart';
```

In the build method, read user data:

```dart
final user = ref.watch(authStateChangesProvider).valueOrNull;
final coupleId = user?.coupleId ?? '';
```

Update the Unlink Partner `ListTile` to be conditionally shown (only when partner exists — for now show always since we can't easily check user2Id from here, but disable in solo mode):

Replace the `_showUnlinkDialog` method's confirm button:

```dart
TextButton(
  onPressed: () async {
    Navigator.pop(context);
    if (coupleId.isNotEmpty) {
      final userId = ref.read(firebaseAuthRepositoryProvider).currentUserId!;
      await ref.read(couplesRepositoryProvider).unlinkPartner(coupleId, userId);
      ref.invalidate(authStateChangesProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Partner unlinked successfully')),
        );
      }
    }
  },
  child: const Text('Unlink'),
),
```

Remove the `// TODO: Call couplesRepository.unlinkPartner()` comment.

Pass `coupleId` and `ref` to `_showUnlinkDialog`:

```dart
void _showUnlinkDialog(BuildContext context, WidgetRef ref, String coupleId) {
```

Update the call site:

```dart
onTap: () => _showUnlinkDialog(context, ref, coupleId),
```

- [ ] **Step 2: Run tests**

Run: `fvm flutter test`
Expected: All tests pass

- [ ] **Step 3: Commit**

```bash
git add lib/src/features/settings/presentation/settings_screen.dart
git commit -m "feat: wire up Unlink Partner to couplesRepository"
```

---

### Task 11: Final Integration Test

- [ ] **Step 1: Run all tests**

Run: `fvm flutter test`
Expected: All tests pass

- [ ] **Step 2: Run analyzer**

Run: `fvm flutter analyze`
Expected: No errors or warnings (info-level is OK)

- [ ] **Step 3: Run the app in Chrome and manually verify**

Run: `fvm flutter run -d chrome`

Test checklist:
1. Register new account with EUR currency → verify € symbol on dashboard
2. Add expense with custom date (pick yesterday) → verify date shows correctly
3. Add expense with note "lunch with team" → verify note shows in list
4. Tap on expense in list → verify edit screen opens with pre-filled data
5. Swipe expense left → verify delete confirmation appears
6. Tap Reports in navigation → verify category breakdown
7. Navigate months in Reports → verify data changes
8. Go to Settings > Unlink Partner → verify dialog and action
9. Verify userName shows next to expenses

- [ ] **Step 4: Final commit if any fixes needed**

```bash
git add -A
git commit -m "fix: integration fixes from manual testing"
```

- [ ] **Step 5: Push to GitHub**

```bash
git push
```
