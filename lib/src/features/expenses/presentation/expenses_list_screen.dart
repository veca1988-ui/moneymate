import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:moneymate/src/constants/app_colors.dart';
import 'package:moneymate/src/constants/app_sizes.dart';
import 'package:moneymate/src/constants/category_icon.dart';
import 'package:moneymate/src/features/auth/data/firebase_auth_repository.dart';
import 'package:moneymate/src/features/expenses/data/expenses_repository_impl.dart';
import 'package:moneymate/src/features/expenses/domain/expense.dart';
import 'package:moneymate/src/features/expenses/presentation/expenses_controller.dart';
import 'package:moneymate/src/utils/currency_helper.dart';

class ExpensesListScreen extends ConsumerStatefulWidget {
  const ExpensesListScreen({
    required this.coupleId,
    required this.month,
    super.key,
  });

  final String coupleId;
  final String month;

  @override
  ConsumerState<ExpensesListScreen> createState() => _ExpensesListScreenState();
}

class _ExpensesListScreenState extends ConsumerState<ExpensesListScreen> {
  String _sortBy = 'date';
  bool _sortAscending = false;
  String _searchQuery = '';
  String? _selectedCategory;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateChangesProvider).valueOrNull;
    final currency = user?.currency ?? 'USD';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                if (_sortBy == value) {
                  _sortAscending = !_sortAscending;
                } else {
                  _sortBy = value;
                  _sortAscending = false;
                }
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'date', child: Text('Date${_sortBy == "date" ? (_sortAscending ? " ↑" : " ↓") : ""}')),
              PopupMenuItem(value: 'amount', child: Text('Amount${_sortBy == "amount" ? (_sortAscending ? " ↑" : " ↓") : ""}')),
              PopupMenuItem(value: 'category', child: Text('Category${_sortBy == "category" ? (_sortAscending ? " ↑" : " ↓") : ""}')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(Sizes.p16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search expenses...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) =>
                  setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Sizes.p16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('All'),
                    selected: _selectedCategory == null,
                    onSelected: (_) =>
                        setState(() => _selectedCategory = null),
                  ),
                ),
                ...[
                  'Groceries',
                  'Dining',
                  'Transport',
                  'Bills',
                  'Entertainment',
                  'Shopping',
                  'Health',
                  'Other',
                ].map(
                  (cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat),
                      selected: _selectedCategory == cat,
                      onSelected: (_) => setState(
                        () => _selectedCategory =
                            _selectedCategory == cat ? null : cat,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Sizes.p8),
          Expanded(
            child: StreamBuilder<List<Expense>>(
              stream: ref
                  .read(expensesRepositoryProvider)
                  .watchExpenses(coupleId: widget.coupleId, month: widget.month),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final expenses = snapshot.data ?? [];

                final filteredExpenses = expenses.where((e) {
                  if (_selectedCategory != null &&
                      e.category != _selectedCategory) return false;
                  if (_searchQuery.isEmpty) return true;
                  return e.category.toLowerCase().contains(_searchQuery) ||
                      e.note.toLowerCase().contains(_searchQuery) ||
                      e.userName.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredExpenses.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(height: Sizes.p16),
                        Text('No expenses yet'),
                      ],
                    ),
                  );
                }

                // Sort the filtered list
                filteredExpenses.sort((a, b) {
                  int result;
                  switch (_sortBy) {
                    case 'amount':
                      result = a.amount.compareTo(b.amount);
                    case 'category':
                      result = a.category.compareTo(b.category);
                    default: // date
                      result = a.date.compareTo(b.date);
                  }
                  return _sortAscending ? result : -result;
                });

                final grouped = <String, List<Expense>>{};
                for (final expense in filteredExpenses) {
                  final dateKey = DateFormat('yyyy-MM-dd').format(expense.date);
                  grouped.putIfAbsent(dateKey, () => []).add(expense);
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(Sizes.p16),
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    final dateKey = grouped.keys.elementAt(index);
                    final dayExpenses = grouped[dateKey]!;
                    final dayTotal =
                        dayExpenses.fold<double>(0, (sum, e) => sum + e.amount);
                    final date = DateTime.parse(dateKey);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: Sizes.p8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('EEEE, MMM d').format(date),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                              ),
                              Text(
                                CurrencyHelper.formatAmount(dayTotal, currency),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      color: AppColors.expense,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        ...dayExpenses.map(
                          (expense) => Dismissible(
                            key: ValueKey(expense.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding:
                                  const EdgeInsets.only(right: Sizes.p16),
                              color: Colors.red,
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              return showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete Expense'),
                                  content: const Text(
                                    'Are you sure you want to delete this expense?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (direction) {
                              ref
                                  .read(expensesControllerProvider.notifier)
                                  .deleteExpense(
                                    coupleId: widget.coupleId,
                                    expenseId: expense.id,
                                  );
                            },
                            child: GestureDetector(
                              onTap: () => context.push(
                                '/edit-expense/${widget.coupleId}',
                                extra: expense,
                              ),
                              child: _ExpenseListTile(
                                expense: expense,
                                currency: currency,
                              ),
                            ),
                          ),
                        ),
                        const Divider(),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseListTile extends StatelessWidget {
  const _ExpenseListTile({required this.expense, required this.currency});
  final Expense expense;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CategoryIcon(category: expense.category),
      title: Text(expense.category),
      subtitle: _buildSubtitle(context),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (expense.visibility == 'private')
            const Padding(
              padding: EdgeInsets.only(right: Sizes.p8),
              child: Icon(Icons.lock, size: 16, color: AppColors.warning),
            ),
          Text(
            CurrencyHelper.formatAmount(expense.amount, currency),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget? _buildSubtitle(BuildContext context) {
    final hasName = expense.userName.isNotEmpty;
    final hasNote = expense.note.isNotEmpty;
    if (!hasName && !hasNote) return null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasName)
          Text(
            expense.userName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
        if (hasNote)
          Text(
            expense.note,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
          ),
      ],
    );
  }
}
