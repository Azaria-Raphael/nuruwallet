import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/enums.dart';

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// Tables
// ---------------------------------------------------------------------------

class TransactionEntries extends Table {
  TextColumn get id => text()();
  RealColumn get amount => real()();
  IntColumn get type => intEnum<TransactionType>()();
  TextColumn get categoryId => text()();
  TextColumn get accountId => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
  TextColumn get receiptImagePath => text().nullable()();
  BoolColumn get isRecurring =>
      boolean().withDefault(const Constant(false))();
  // 'daily' | 'weekly' | 'monthly' | 'yearly'
  TextColumn get recurrenceInterval => text().nullable()();
  TextColumn get currencyCode =>
      text().withDefault(const Constant('TZS'))();
  RealColumn get originalAmount => real().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CategoryEntries extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get iconName => text()();
  IntColumn get colorValue => integer()();
  RealColumn get monthlyLimit =>
      real().withDefault(const Constant(0.0))();
  // 'expense' | 'income' | 'both'
  TextColumn get categoryType =>
      text().withDefault(const Constant('expense'))();
  TextColumn get parentCategoryId => text().nullable()();
  BoolColumn get isDefault =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get rolloverEnabled =>
      boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class AccountEntries extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get type => intEnum<AccountType>()();
  RealColumn get balance => real().withDefault(const Constant(0.0))();
  IntColumn get colorValue => integer()();
  BoolColumn get isDefault =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class SavingsGoalEntries extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get iconName => text()();
  RealColumn get targetAmount => real()();
  RealColumn get currentAmount =>
      real().withDefault(const Constant(0.0))();
  DateTimeColumn get deadline => dateTime()();
  TextColumn get note => text().nullable()();
  BoolColumn get isPaused =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isCompleted =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ExchangeRateCacheEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get baseCurrency => text()();
  // Serialised Map<String, double> as JSON string
  TextColumn get ratesJson => text()();
  DateTimeColumn get fetchedAt => dateTime()();
  TextColumn get source => text()();
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

@DriftDatabase(tables: [
  TransactionEntries,
  CategoryEntries,
  AccountEntries,
  SavingsGoalEntries,
  ExchangeRateCacheEntries,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Used in tests to inject an in-memory executor.
  // ignore: use_super_parameters
  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'nuruwallet_db');
  }

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(savingsGoalEntries, savingsGoalEntries.note);
        await m.addColumn(categoryEntries, categoryEntries.categoryType);
      }
      if (from < 3) {
        await m.database.customStatement(
          'ALTER TABLE transaction_entries '
          'ADD COLUMN recurrence_interval TEXT',
        );
      }
    },
  );
}
