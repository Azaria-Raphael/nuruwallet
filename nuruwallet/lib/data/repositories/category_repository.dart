import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';

class CategoryRepository {
  CategoryRepository(this._db);

  final AppDatabase _db;
  final _uuid = const Uuid();

  // --- Write ---

  Future<void> add({
    required String name,
    required String iconName,
    required int colorValue,
    String categoryType = 'expense',
    double monthlyLimit = 0.0,
    String? parentCategoryId,
    bool isDefault = false,
    bool rolloverEnabled = false,
    int sortOrder = 0,
  }) async {
    await _db.into(_db.categoryEntries).insert(
          CategoryEntriesCompanion.insert(
            id: _uuid.v4(),
            name: name,
            iconName: iconName,
            colorValue: colorValue,
            categoryType: Value(categoryType),
            monthlyLimit: Value(monthlyLimit),
            parentCategoryId: Value(parentCategoryId),
            isDefault: Value(isDefault),
            rolloverEnabled: Value(rolloverEnabled),
            sortOrder: Value(sortOrder),
          ),
        );
  }

  Future<void> update(CategoryEntry entry) async {
    await _db.update(_db.categoryEntries).replace(entry);
  }

  Future<void> setMonthlyLimit(String id, double limit) async {
    await (_db.update(_db.categoryEntries)..where((c) => c.id.equals(id)))
        .write(CategoryEntriesCompanion(monthlyLimit: Value(limit)));
  }

  Future<void> deleteById(String id) async {
    await (_db.delete(_db.categoryEntries)..where((c) => c.id.equals(id))).go();
  }

  Future<void> reorderCategories(List<CategoryEntry> reordered) async {
    for (int i = 0; i < reordered.length; i++) {
      await (_db.update(_db.categoryEntries)
            ..where((c) => c.id.equals(reordered[i].id)))
          .write(CategoryEntriesCompanion(sortOrder: Value(i)));
    }
  }

  Future<void> resetAllLimits() async {
    await _db.update(_db.categoryEntries).write(
      const CategoryEntriesCompanion(monthlyLimit: Value(0.0)),
    );
  }

  // --- Read ---

  Future<List<CategoryEntry>> getAll() {
    return (_db.select(_db.categoryEntries)
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .get();
  }

  Future<CategoryEntry?> getById(String id) {
    return (_db.select(_db.categoryEntries)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  Stream<List<CategoryEntry>> watchAll() {
    return (_db.select(_db.categoryEntries)
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .watch();
  }

  /// Returns categories whose type is in [types] (e.g. ['expense','both']).
  Stream<List<CategoryEntry>> watchByTypes(List<String> types) {
    return (_db.select(_db.categoryEntries)
          ..where((c) => c.categoryType.isIn(types))
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .watch();
  }

  // --- Seeding ---

  Future<void> seedDefaultsIfEmpty() async {
    final existing = await getAll();
    if (existing.isNotEmpty) return;

    const expenseDefaults = [
      (name: 'Food & Drinks',  icon: 'food',          color: 0xFFEF5350, sort: 0),
      (name: 'Transport',      icon: 'transport',     color: 0xFF42A5F5, sort: 1),
      (name: 'Housing & Rent', icon: 'home',          color: 0xFF66BB6A, sort: 2),
      (name: 'Health',         icon: 'health',        color: 0xFFEC407A, sort: 3),
      (name: 'Entertainment',  icon: 'entertainment', color: 0xFFAB47BC, sort: 4),
      (name: 'Education',      icon: 'education',     color: 0xFF26C6DA, sort: 5),
      (name: 'Shopping',       icon: 'shopping',      color: 0xFFFF7043, sort: 6),
      (name: 'Utilities',      icon: 'utilities',     color: 0xFF8D6E63, sort: 7),
      (name: 'Savings',        icon: 'savings',       color: 0xFF26A69A, sort: 8),
      (name: 'Other',          icon: 'other',         color: 0xFF78909C, sort: 9),
    ];

    for (final d in expenseDefaults) {
      await add(
        name: d.name,
        iconName: d.icon,
        colorValue: d.color,
        categoryType: 'expense',
        isDefault: true,
        sortOrder: d.sort,
      );
    }

    await _seedIncomeDefaults();
  }

  /// Seeds income categories. Safe to call multiple times — no-op if any
  /// income category already exists.
  Future<void> seedIncomeCategoriesIfMissing() async {
    final existing = await getAll();
    if (existing.any((c) => c.categoryType == 'income')) return;
    await _seedIncomeDefaults();
  }

  Future<void> _seedIncomeDefaults() async {
    const incomeDefaults = [
      (name: 'Salary',        icon: 'salary',       color: 0xFF26A69A, sort: 100),
      (name: 'Business',      icon: 'business',     color: 0xFF42A5F5, sort: 101),
      (name: 'Freelance',     icon: 'freelance',    color: 0xFF7E57C2, sort: 102),
      (name: 'Investments',   icon: 'investments',  color: 0xFF66BB6A, sort: 103),
      (name: 'Gifts',         icon: 'gift',         color: 0xFFEC407A, sort: 104),
      (name: 'Rental Income', icon: 'rental',       color: 0xFFFF7043, sort: 105),
      (name: 'Other Income',  icon: 'other_income', color: 0xFF78909C, sort: 106),
    ];

    for (final d in incomeDefaults) {
      await add(
        name: d.name,
        iconName: d.icon,
        colorValue: d.color,
        categoryType: 'income',
        isDefault: true,
        sortOrder: d.sort,
      );
    }
  }
}
