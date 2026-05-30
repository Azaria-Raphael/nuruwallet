import '../../data/models/enums.dart';
import '../../data/repositories/account_repository.dart';
import '../../data/repositories/transaction_repository.dart';

class RecurringTransactionService {
  RecurringTransactionService({
    required this.transactionRepo,
    required this.accountRepo,
  });

  final TransactionRepository transactionRepo;
  final AccountRepository accountRepo;

  Future<void> processRecurring() async {
    final templates = await transactionRepo.getRecurring();
    final now = DateTime.now();

    for (final t in templates) {
      final interval = t.recurrenceInterval;
      if (interval == null) continue;

      final nextDue = _nextDue(t.date, interval);
      if (nextDue.isAfter(now)) continue;

      // Create the new transaction for this period
      await transactionRepo.add(
        amount: t.amount,
        type: t.type,
        categoryId: t.categoryId,
        accountId: t.accountId,
        date: nextDue,
        note: t.note,
        isRecurring: true,
        recurrenceInterval: interval,
        currencyCode: t.currencyCode,
      );

      // Reflect in account balance
      final delta = t.type == TransactionType.income ? t.amount : -t.amount;
      await accountRepo.adjustBalance(t.accountId, delta);

      // Advance source date so the next due period is calculated correctly
      await transactionRepo.update(t.copyWith(date: nextDue));
    }
  }

  static DateTime _nextDue(DateTime last, String interval) {
    return switch (interval) {
      'daily' => last.add(const Duration(days: 1)),
      'weekly' => last.add(const Duration(days: 7)),
      'monthly' => DateTime(
          last.year, last.month + 1, last.day, last.hour, last.minute),
      'yearly' =>
        DateTime(last.year + 1, last.month, last.day, last.hour, last.minute),
      _ => last,
    };
  }
}
