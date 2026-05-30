import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../models/enums.dart';

class AccountRepository {
  AccountRepository(this._db);

  final AppDatabase _db;
  final _uuid = const Uuid();

  // --- Write ---

  Future<void> add({
    required String name,
    required AccountType type,
    required int colorValue,
    double balance = 0.0,
    bool isDefault = false,
  }) async {
    await _db.into(_db.accountEntries).insert(
          AccountEntriesCompanion.insert(
            id: _uuid.v4(),
            name: name,
            type: type,
            colorValue: colorValue,
            balance: Value(balance),
            isDefault: Value(isDefault),
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<void> update(AccountEntry entry) async {
    await _db.update(_db.accountEntries).replace(entry);
  }

  Future<void> updateBalance(String id, double newBalance) async {
    await (_db.update(_db.accountEntries)
          ..where((a) => a.id.equals(id)))
        .write(AccountEntriesCompanion(balance: Value(newBalance)));
  }

  Future<void> adjustBalance(String id, double delta) async {
    final account = await getById(id);
    if (account == null) return;
    await updateBalance(id, account.balance + delta);
  }

  Future<void> deleteById(String id) async {
    await (_db.delete(_db.accountEntries)
          ..where((a) => a.id.equals(id)))
        .go();
  }

  Future<void> deleteAll() => _db.delete(_db.accountEntries).go();

  // --- Read ---

  Future<List<AccountEntry>> getAll() {
    return (_db.select(_db.accountEntries)
          ..orderBy([
            (a) => OrderingTerm.desc(a.isDefault),
            (a) => OrderingTerm.asc(a.createdAt),
          ]))
        .get();
  }

  Future<AccountEntry?> getById(String id) {
    return (_db.select(_db.accountEntries)
          ..where((a) => a.id.equals(id)))
        .getSingleOrNull();
  }

  Future<AccountEntry?> getDefault() {
    return (_db.select(_db.accountEntries)
          ..where((a) => a.isDefault.equals(true)))
        .getSingleOrNull();
  }

  Future<double> getTotalBalance() async {
    final accounts = await getAll();
    return accounts.fold<double>(0.0, (sum, a) => sum + a.balance);
  }

  Stream<List<AccountEntry>> watchAll() {
    return (_db.select(_db.accountEntries)
          ..orderBy([
            (a) => OrderingTerm.desc(a.isDefault),
            (a) => OrderingTerm.asc(a.createdAt),
          ]))
        .watch();
  }

  Stream<double> watchTotalBalance() {
    return watchAll().map(
      (accounts) => accounts.fold(0.0, (sum, a) => sum + a.balance),
    );
  }

  // --- Seeding ---

  Future<void> seedDefaultIfEmpty() async {
    final existing = await getAll();
    if (existing.isNotEmpty) return;

    await add(
      name: 'Cash Wallet',
      type: AccountType.cash,
      colorValue: 0xFF0D9488,
      isDefault: true,
    );
  }
}
