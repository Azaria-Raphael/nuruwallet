import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/database/app_database.dart';
import '../../../data/models/enums.dart';
import '../../../data/providers/repository_providers.dart';
import '../widgets/add_transaction_sheet.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() =>
      _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _searchController = TextEditingController();
  bool _searching = false;
  String _query = '';
  TransactionType? _typeFilter;
  DateTimeRange? _dateRange;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TransactionEntry> _applyFilters(
    List<TransactionEntry> all,
    Map<String, CategoryEntry> catsMap,
    Map<String, AccountEntry> accountsMap,
  ) {
    var list = all;
    if (_typeFilter != null) {
      list = list.where((t) => t.type == _typeFilter).toList();
    }
    if (_dateRange != null) {
      final start = _dateRange!.start;
      final end = _dateRange!.end
          .add(const Duration(hours: 23, minutes: 59, seconds: 59));
      list = list
          .where((t) => !t.date.isBefore(start) && !t.date.isAfter(end))
          .toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((t) {
        final cat = catsMap[t.categoryId]?.name.toLowerCase() ?? '';
        final acc = accountsMap[t.accountId]?.name.toLowerCase() ?? '';
        final note = t.note?.toLowerCase() ?? '';
        final amount = t.amount.toStringAsFixed(0);
        return cat.contains(q) ||
            acc.contains(q) ||
            note.contains(q) ||
            amount.contains(q);
      }).toList();
    }
    return list;
  }

  void _clearSearch() {
    setState(() {
      _searching = false;
      _query = '';
      _searchController.clear();
    });
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (picked != null && mounted) setState(() => _dateRange = picked);
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(allTransactionsProvider);
    final catsMap = ref.watch(categoriesMapProvider).valueOrNull ?? {};
    final accountsMap = ref.watch(accountsMapProvider).valueOrNull ?? {};

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search by category, note, amount…',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.45),
                    fontSize: 15,
                  ),
                ),
                style: const TextStyle(fontSize: 15),
                onChanged: (v) => setState(() => _query = v),
              )
            : const Text(AppStrings.navTransactions),
        actions: [
          if (_searching)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Clear search',
              onPressed: _clearSearch,
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Search',
              onPressed: () => setState(() => _searching = true),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips (type + date range) — horizontally scrollable
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _TypeChip(
                    label: 'All',
                    selected: _typeFilter == null,
                    onTap: () => setState(() => _typeFilter = null),
                  ),
                  const SizedBox(width: 8),
                  _TypeChip(
                    label: 'Income',
                    selected: _typeFilter == TransactionType.income,
                    color: AppColors.income,
                    onTap: () => setState(
                        () => _typeFilter = TransactionType.income),
                  ),
                  const SizedBox(width: 8),
                  _TypeChip(
                    label: 'Expense',
                    selected: _typeFilter == TransactionType.expense,
                    color: AppColors.expense,
                    onTap: () => setState(
                        () => _typeFilter = TransactionType.expense),
                  ),
                  const SizedBox(width: 8),
                  _DateRangeChip(
                    dateRange: _dateRange,
                    onTap: _pickDateRange,
                    onClear: () => setState(() => _dateRange = null),
                  ),
                ],
              ),
            ),
          ),

          // Transaction list
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                final filtered =
                    _applyFilters(transactions, catsMap, accountsMap);

                if (transactions.isEmpty) {
                  return _EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: AppStrings.noTransactions,
                    subtitle: AppStrings.noTransactionsHint,
                  );
                }

                if (filtered.isEmpty) {
                  return _EmptyState(
                    icon: Icons.search_off,
                    title: 'No results',
                    subtitle: 'Try a different search or filter.',
                  );
                }

                final groups = <String, List<TransactionEntry>>{};
                for (final t in filtered) {
                  groups
                      .putIfAbsent(
                          DateFormatter.groupHeader(t.date), () => [])
                      .add(t);
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final header = groups.keys.elementAt(index);
                    final group = groups[header]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            header,
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.5),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                          ),
                        ),
                        Card(
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              for (int i = 0;
                                  i < group.length;
                                  i++) ...[
                                _TransactionTile(
                                  transaction: group[i],
                                  category:
                                      catsMap[group[i].categoryId],
                                  accountName: accountsMap[
                                          group[i].accountId]
                                      ?.name,
                                  onEdit: () =>
                                      showAddTransactionSheet(
                                    context,
                                    transaction: group[i],
                                  ),
                                  onDelete: () => _deleteTransaction(
                                      context, ref, group[i]),
                                ),
                                if (i < group.length - 1)
                                  const Divider(
                                      height: 1, indent: 56),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddTransactionSheet(context),
        tooltip: AppStrings.addTransaction,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteTransaction(
    BuildContext context,
    WidgetRef ref,
    TransactionEntry t,
  ) async {
    await ref.read(transactionRepositoryProvider).deleteById(t.id);
    final delta =
        t.type == TransactionType.income ? -t.amount : t.amount;
    await ref
        .read(accountRepositoryProvider)
        .adjustBalance(t.accountId, delta);
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4),
                ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter chips
// ---------------------------------------------------------------------------

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primary;
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? activeColor.withValues(alpha: 0.12)
              : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? Border.all(color: activeColor, width: 1.5)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight:
                selected ? FontWeight.w700 : FontWeight.normal,
            color: selected
                ? activeColor
                : scheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}

class _DateRangeChip extends StatelessWidget {
  const _DateRangeChip({
    required this.dateRange,
    required this.onTap,
    required this.onClear,
  });

  final DateTimeRange? dateRange;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isActive = dateRange != null;
    const activeColor = AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: 0.12)
              : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? Border.all(color: activeColor, width: 1.5)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.date_range_outlined,
              size: 14,
              color: isActive
                  ? activeColor
                  : scheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              isActive
                  ? '${DateFormatter.dayMonth(dateRange!.start)} – '
                      '${DateFormatter.dayMonth(dateRange!.end)}'
                  : 'Date',
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.normal,
                color: isActive
                    ? activeColor
                    : scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close,
                    size: 14, color: activeColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Transaction tile (swipe to delete)
// ---------------------------------------------------------------------------

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.category,
    required this.onEdit,
    required this.onDelete,
    this.accountName,
  });

  final TransactionEntry transaction;
  final CategoryEntry? category;
  final String? accountName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final isExpense = t.type == TransactionType.expense;
    final typeColor = isExpense ? AppColors.expense : AppColors.income;

    return Dismissible(
      key: Key(t.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.expense.withValues(alpha: 0.85),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 22),
            SizedBox(height: 2),
            Text(
              'Delete',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        onTap: onEdit,
        leading: CircleAvatar(
          backgroundColor: typeColor.withValues(alpha: 0.1),
          child: Icon(
            isExpense ? Icons.arrow_upward : Icons.arrow_downward,
            color: typeColor,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                category?.name ??
                    (isExpense
                        ? AppStrings.expense
                        : AppStrings.income),
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (t.isRecurring)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.repeat,
                  size: 14,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4),
                ),
              ),
          ],
        ),
        subtitle: _Subtitle(
            transaction: t,
            category: category,
            accountName: accountName),
        trailing: Text(
          CurrencyFormatter.formatWithSign(
            isExpense ? -t.amount : t.amount,
            currencyCode: t.currencyCode,
          ),
          style: TextStyle(
            color: typeColor,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(AppStrings.deleteTransactionConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
                foregroundColor: AppColors.expense),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle({
    required this.transaction,
    required this.category,
    this.accountName,
  });

  final TransactionEntry transaction;
  final CategoryEntry? category;
  final String? accountName;

  @override
  Widget build(BuildContext context) {
    final note = transaction.note;
    final muted = Theme.of(context)
        .colorScheme
        .onSurface
        .withValues(alpha: 0.5);
    return Row(
      children: [
        if (accountName != null) ...[
          Text(
            accountName!,
            style: TextStyle(fontSize: 12, color: muted),
            overflow: TextOverflow.ellipsis,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child:
                Text('·', style: TextStyle(fontSize: 12, color: muted)),
          ),
        ],
        Text(
          DateFormatter.dateTime(transaction.date),
          style: TextStyle(fontSize: 12, color: muted),
        ),
        if (note != null && note.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child:
                Text('·', style: TextStyle(fontSize: 12, color: muted)),
          ),
          Flexible(
            child: Text(
              note,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        if (transaction.receiptImagePath != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(Icons.attach_file, size: 12, color: muted),
          ),
        ],
      ],
    );
  }
}
