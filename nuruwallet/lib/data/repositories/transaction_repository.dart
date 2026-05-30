import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../models/enums.dart';

class TransactionRepository {
  TransactionRepository(this._db);

  final AppDatabase _db;
  final _uuid = const Uuid();

  // --- Write ---

  Future<void> add({
    required double amount,
    required TransactionType type,
    required String categoryId,
    required String accountId,
    required DateTime date,
    String? note,
    String? receiptImagePath,
    bool isRecurring = false,
    String? recurrenceInterval,
    String currencyCode = 'TZS',
    double? originalAmount,
  }) async {
    await _db.into(_db.transactionEntries).insert(
          TransactionEntriesCompanion.insert(
            id: _uuid.v4(),
            amount: amount,
            type: type,
            categoryId: categoryId,
            accountId: accountId,
            date: date,
            note: Value(note),
            receiptImagePath: Value(receiptImagePath),
            isRecurring: Value(isRecurring),
            recurrenceInterval: Value(recurrenceInterval),
            currencyCode: Value(currencyCode),
            originalAmount: Value(originalAmount),
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<void> update(TransactionEntry entry) async {
    await _db.update(_db.transactionEntries).replace(entry);
  }

  Future<void> deleteById(String id) async {
    await (_db.delete(_db.transactionEntries)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  Future<void> deleteAll() => _db.delete(_db.transactionEntries).go();

  // --- Read (one-shot) ---

  Future<List<TransactionEntry>> getAll() {
    return (_db.select(_db.transactionEntries)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<List<TransactionEntry>> getByAccount(String accountId) {
    return (_db.select(_db.transactionEntries)
          ..where((t) => t.accountId.equals(accountId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<List<TransactionEntry>> getByCategory(String categoryId) {
    return (_db.select(_db.transactionEntries)
          ..where((t) => t.categoryId.equals(categoryId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<List<TransactionEntry>> getRecurring() {
    return (_db.select(_db.transactionEntries)
          ..where((t) => t.isRecurring.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
  }

  Future<List<TransactionEntry>> getByDateRange(
      DateTime from, DateTime to) {
    return (_db.select(_db.transactionEntries)
          ..where((t) =>
              t.date.isBetweenValues(from, to))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<List<TransactionEntry>> getForMonth(int year, int month) {
    final from = DateTime(year, month, 1);
    final to = DateTime(year, month + 1, 1)
        .subtract(const Duration(milliseconds: 1));
    return getByDateRange(from, to);
  }

  Future<double> sumByTypeForMonth(
      TransactionType type, int year, int month) async {
    final rows = await getForMonth(year, month);
    return rows
        .where((t) => t.type == type)
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  Future<double> sumByCategoryForMonth(
      String categoryId, int year, int month) async {
    final rows = await getForMonth(year, month);
    return rows
        .where((t) =>
            t.categoryId == categoryId &&
            t.type == TransactionType.expense)
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  // --- Watch (reactive streams) ---

  Stream<List<TransactionEntry>> watchAll() {
    return (_db.select(_db.transactionEntries)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Stream<List<TransactionEntry>> watchRecent(int limit) {
    return (_db.select(_db.transactionEntries)
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(limit))
        .watch();
  }

  Stream<List<TransactionEntry>> watchByAccount(String accountId) {
    return (_db.select(_db.transactionEntries)
          ..where((t) => t.accountId.equals(accountId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Stream<List<TransactionEntry>> watchForMonth(int year, int month) {
    final from = DateTime(year, month, 1);
    final to = DateTime(year, month + 1, 1)
        .subtract(const Duration(milliseconds: 1));
    return (_db.select(_db.transactionEntries)
          ..where((t) => t.date.isBetweenValues(from, to))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }
}
