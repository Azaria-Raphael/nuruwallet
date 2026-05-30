import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/account_icon.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/database/app_database.dart';
import '../../../data/models/enums.dart';
import '../../../data/providers/repository_providers.dart';
import '../../accounts/widgets/account_detail_sheet.dart';
import '../../accounts/widgets/add_edit_account_sheet.dart';
import '../../settings/screens/settings_screen.dart';
import '../../transactions/widgets/add_transaction_sheet.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(totalBalanceProvider);
    final accountsAsync = ref.watch(allAccountsProvider);
    final recentAsync = ref.watch(recentTransactionsProvider);
    final catsMap = ref.watch(categoriesMapProvider).valueOrNull ?? {};
    final accountsMap = ref.watch(accountsMapProvider).valueOrNull ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allTransactionsProvider);
          ref.invalidate(allAccountsProvider);
          ref.invalidate(totalBalanceProvider);
          ref.invalidate(recentTransactionsProvider);
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- Balance card ---
            Card(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppStrings.totalBalance,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    balanceAsync.when(
                      data: (balance) => Text(
                        CurrencyFormatter.format(balance),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      loading: () => const Text(
                        '...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      error: (_, _) => const Text(
                        'TZS 0',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- Accounts ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.myAccounts,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                TextButton(
                  onPressed: () => showAddEditAccountSheet(context),
                  child: const Text(AppStrings.addAccount),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: accountsAsync.when(
                data: (accounts) => ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: accounts.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    if (i == accounts.length) {
                      return _AddAccountCard(
                        onTap: () => showAddEditAccountSheet(context),
                      );
                    }
                    return _AccountCard(
                      account: accounts[i],
                      onTap: () => showAccountDetailSheet(
                        context,
                        accounts[i],
                      ),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ),

            const SizedBox(height: 24),

            // --- Recent transactions ---
            Text(
              AppStrings.recentTransactions,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),

            recentAsync.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 48,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppStrings.noTransactions,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.5),
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.noTransactionsHint,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.4),
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Card(
                  child: Column(
                    children: [
                      for (int i = 0; i < transactions.length; i++) ...[
                        Builder(builder: (context) {
                          final t = transactions[i];
                          final isExpense =
                              t.type == TransactionType.expense;
                          final typeColor = isExpense
                              ? AppColors.expense
                              : AppColors.income;
                          final cat = catsMap[t.categoryId];
                          return ListTile(
                            onTap: () => showAddTransactionSheet(
                              context,
                              transaction: t,
                            ),
                            leading: CircleAvatar(
                              backgroundColor:
                                  typeColor.withValues(alpha: 0.1),
                              child: Icon(
                                isExpense
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: typeColor,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              cat?.name ??
                                  (isExpense
                                      ? AppStrings.expense
                                      : AppStrings.income),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: _DashTileSubtitle(
                                transaction: t,
                                accountName:
                                    accountsMap[t.accountId]?.name),
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
                          );
                        }),
                        if (i < transactions.length - 1)
                          const Divider(height: 1, indent: 56),
                      ],
                    ],
                  ),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddTransactionSheet(context),
        tooltip: AppStrings.addTransaction,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.account, required this.onTap});

  final AccountEntry account;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color(account.colorValue);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(AccountIcon.get(account.type), color: Colors.white, size: 22),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  CurrencyFormatter.formatCompact(account.balance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DashTileSubtitle extends StatelessWidget {
  const _DashTileSubtitle(
      {required this.transaction, this.accountName});
  final TransactionEntry transaction;
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
            child: Text('·', style: TextStyle(fontSize: 12, color: muted)),
          ),
        ],
        Text(
          DateFormatter.dateTime(transaction.date),
          style: TextStyle(fontSize: 12, color: muted),
        ),
        if (note != null && note.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text('·', style: TextStyle(fontSize: 12, color: muted)),
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

class _AddAccountCard extends StatelessWidget {
  const _AddAccountCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: scheme.onSurface.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: scheme.onSurface.withValues(alpha: 0.4),
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.addAccount,
              style: TextStyle(
                fontSize: 11,
                color: scheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
