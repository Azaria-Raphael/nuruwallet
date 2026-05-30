import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../models/enums.dart';
import '../repositories/account_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/exchange_rate_repository.dart';
import '../repositories/goal_repository.dart';
import '../repositories/transaction_repository.dart';
import 'database_provider.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(ref.watch(databaseProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(databaseProvider));
});

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepository(ref.watch(databaseProvider));
});

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return GoalRepository(ref.watch(databaseProvider));
});

final exchangeRateRepositoryProvider =
    Provider<ExchangeRateRepository>((ref) {
  return ExchangeRateRepository(ref.watch(databaseProvider));
});

// ---------------------------------------------------------------------------
// Reactive stream providers — UI widgets watch these directly
// ---------------------------------------------------------------------------

final allTransactionsProvider = StreamProvider((ref) {
  return ref.watch(transactionRepositoryProvider).watchAll();
});

final recentTransactionsProvider = StreamProvider((ref) {
  return ref.watch(transactionRepositoryProvider).watchRecent(10);
});

final allCategoriesProvider = StreamProvider((ref) {
  return ref.watch(categoryRepositoryProvider).watchAll();
});

final expenseCategoriesProvider = StreamProvider((ref) {
  return ref
      .watch(categoryRepositoryProvider)
      .watchByTypes(['expense', 'both']);
});

final incomeCategoriesProvider = StreamProvider((ref) {
  return ref
      .watch(categoryRepositoryProvider)
      .watchByTypes(['income', 'both']);
});

final allAccountsProvider = StreamProvider((ref) {
  return ref.watch(accountRepositoryProvider).watchAll();
});

final totalBalanceProvider = StreamProvider<double>((ref) {
  return ref.watch(accountRepositoryProvider).watchTotalBalance();
});

final activeGoalsProvider = StreamProvider((ref) {
  return ref.watch(goalRepositoryProvider).watchActive();
});

final allGoalsProvider = StreamProvider((ref) {
  return ref.watch(goalRepositoryProvider).watchAll();
});

final latestExchangeRateProvider = StreamProvider((ref) {
  return ref.watch(exchangeRateRepositoryProvider).watchLatest();
});

// Convenience map of account id → AccountEntry for O(1) lookup in UI.
final accountsMapProvider = StreamProvider<Map<String, AccountEntry>>((ref) {
  return ref.watch(accountRepositoryProvider).watchAll().map(
        (accounts) => {for (final a in accounts) a.id: a},
      );
});

// All transactions for a single account (reactive).
final accountTransactionsProvider =
    StreamProvider.family<List<TransactionEntry>, String>((ref, accountId) {
  return ref.watch(transactionRepositoryProvider).watchByAccount(accountId);
});

// Convenience map of category id → CategoryEntry for O(1) lookup in UI.
final categoriesMapProvider =
    StreamProvider<Map<String, CategoryEntry>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchAll().map(
        (cats) => {for (final c in cats) c.id: c},
      );
});

// Current month income + expense totals (reactive).
final currentMonthSummaryProvider =
    StreamProvider<({double income, double expense})>((ref) {
  final now = DateTime.now();
  return ref
      .watch(transactionRepositoryProvider)
      .watchForMonth(now.year, now.month)
      .map((txs) {
    double inc = 0, exp = 0;
    for (final t in txs) {
      if (t.type == TransactionType.income) {
        inc += t.amount;
      } else {
        exp += t.amount;
      }
    }
    return (income: inc, expense: exp);
  });
});

// Last 6 calendar months' income + expense totals (one-shot).
typedef MonthSummary = ({int year, int month, double income, double expense});

final last6MonthsSummaryProvider =
    FutureProvider<List<MonthSummary>>((ref) async {
  final repo = ref.read(transactionRepositoryProvider);
  final now = DateTime.now();
  final results = <MonthSummary>[];
  for (int i = 5; i >= 0; i--) {
    final dt = DateTime(now.year, now.month - i);
    final income = await repo.sumByTypeForMonth(
        TransactionType.income, dt.year, dt.month);
    final expense = await repo.sumByTypeForMonth(
        TransactionType.expense, dt.year, dt.month);
    results.add(
        (year: dt.year, month: dt.month, income: income, expense: expense));
  }
  return results;
});

// Maps category id → total TZS spent in the previous calendar month.
final previousMonthSpendingProvider =
    StreamProvider<Map<String, double>>((ref) {
  final now = DateTime.now();
  final prev = DateTime(now.year, now.month - 1);
  return ref
      .watch(transactionRepositoryProvider)
      .watchForMonth(prev.year, prev.month)
      .map((transactions) {
    final map = <String, double>{};
    for (final t in transactions) {
      if (t.type == TransactionType.expense) {
        map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
      }
    }
    return map;
  });
});

// Maps category id → total TZS spent in the current calendar month.
final currentMonthSpendingProvider =
    StreamProvider<Map<String, double>>((ref) {
  final now = DateTime.now();
  return ref
      .watch(transactionRepositoryProvider)
      .watchForMonth(now.year, now.month)
      .map((transactions) {
    final map = <String, double>{};
    for (final t in transactions) {
      if (t.type == TransactionType.expense) {
        map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
      }
    }
    return map;
  });
});
