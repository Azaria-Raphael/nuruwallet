import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/account_icon.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/database/app_database.dart';
import '../../../data/models/enums.dart';
import '../../../data/providers/repository_providers.dart';
import 'add_edit_account_sheet.dart';

void showAccountDetailSheet(BuildContext context, AccountEntry account) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => AccountDetailSheet(account: account),
  );
}

class AccountDetailSheet extends ConsumerWidget {
  const AccountDetailSheet({super.key, required this.account});

  final AccountEntry account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(accountTransactionsProvider(account.id));
    final catsMap = ref.watch(categoriesMapProvider).valueOrNull ?? {};
    final color = Color(account.colorValue);
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Icon(AccountIcon.get(account.type),
                      color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        account.type.label,
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    showAddEditAccountSheet(context, account: account);
                  },
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Balance + stats card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: txAsync.when(
              data: (txs) {
                double income = 0, expense = 0;
                for (final t in txs) {
                  if (t.type == TransactionType.income) {
                    income += t.amount;
                  } else {
                    expense += t.amount;
                  }
                }
                final net = income - expense;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          CurrencyFormatter.format(account.balance),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Current Balance',
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatChip(
                              label: 'Income',
                              value: income,
                              color: AppColors.income,
                            ),
                            Container(
                              width: 1,
                              height: 32,
                              color: scheme.outlineVariant,
                            ),
                            _StatChip(
                              label: 'Expense',
                              value: expense,
                              color: AppColors.expense,
                            ),
                            Container(
                              width: 1,
                              height: 32,
                              color: scheme.outlineVariant,
                            ),
                            _StatChip(
                              label: 'Net',
                              value: net.abs(),
                              color: net >= 0
                                  ? AppColors.income
                                  : AppColors.expense,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Transactions',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),

          // Transaction list
          Expanded(
            child: txAsync.when(
              data: (txs) {
                if (txs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'No transactions yet',
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: txs.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, indent: 48),
                  itemBuilder: (context, i) {
                    final t = txs[i];
                    final isExpense = t.type == TransactionType.expense;
                    final typeColor =
                        isExpense ? AppColors.expense : AppColors.income;
                    final cat = catsMap[t.categoryId];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: typeColor.withValues(alpha: 0.1),
                        child: Icon(
                          isExpense
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: typeColor,
                          size: 16,
                        ),
                      ),
                      title: Text(
                        cat?.name ??
                            (isExpense ? 'Expense' : 'Income'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        DateFormatter.dateTime(t.date),
                        style: TextStyle(
                          fontSize: 11,
                          color: scheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      trailing: Text(
                        CurrencyFormatter.formatWithSign(
                          isExpense ? -t.amount : t.amount,
                          currencyCode: t.currencyCode,
                        ),
                        style: TextStyle(
                          color: typeColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
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
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          CurrencyFormatter.formatCompact(value),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
