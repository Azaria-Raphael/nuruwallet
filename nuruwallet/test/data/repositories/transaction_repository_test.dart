import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuruwallet/data/database/app_database.dart';
import 'package:nuruwallet/data/models/enums.dart';
import 'package:nuruwallet/data/repositories/transaction_repository.dart';

void main() {
  group('TransactionRepository', () {
    late AppDatabase db;
    late TransactionRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = TransactionRepository(db);
    });

    tearDown(() async => db.close());

    test('add 3 transactions and read them back', () async {
      await repo.add(
        amount: 5000,
        type: TransactionType.expense,
        categoryId: 'cat_1',
        accountId: 'acc_1',
        date: DateTime(2026, 5, 1),
      );
      await repo.add(
        amount: 200000,
        type: TransactionType.income,
        categoryId: 'cat_2',
        accountId: 'acc_1',
        date: DateTime(2026, 5, 2),
      );
      await repo.add(
        amount: 12500,
        type: TransactionType.expense,
        categoryId: 'cat_1',
        accountId: 'acc_1',
        date: DateTime(2026, 5, 3),
      );

      final all = await repo.getAll();
      expect(all.length, 3);

      // Most recent first
      expect(all.first.date, DateTime(2026, 5, 3));
      expect(all.last.date, DateTime(2026, 5, 1));
    });

    test('sumByTypeForMonth sums income and expense correctly', () async {
      await repo.add(
        amount: 300000,
        type: TransactionType.income,
        categoryId: 'cat_1',
        accountId: 'acc_1',
        date: DateTime(2026, 5, 10),
      );
      await repo.add(
        amount: 45000,
        type: TransactionType.expense,
        categoryId: 'cat_2',
        accountId: 'acc_1',
        date: DateTime(2026, 5, 11),
      );

      final income =
          await repo.sumByTypeForMonth(TransactionType.income, 2026, 5);
      final expense =
          await repo.sumByTypeForMonth(TransactionType.expense, 2026, 5);

      expect(income, 300000.0);
      expect(expense, 45000.0);
    });
  });
}
