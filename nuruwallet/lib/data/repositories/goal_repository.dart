import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';

class GoalRepository {
  GoalRepository(this._db);

  final AppDatabase _db;
  final _uuid = const Uuid();

  // --- Write ---

  Future<void> add({
    required String name,
    required String iconName,
    required double targetAmount,
    required DateTime deadline,
    String? note,
  }) async {
    await _db.into(_db.savingsGoalEntries).insert(
          SavingsGoalEntriesCompanion.insert(
            id: _uuid.v4(),
            name: name,
            iconName: iconName,
            targetAmount: targetAmount,
            deadline: deadline,
            note: Value(note),
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<void> update(SavingsGoalEntry entry) async {
    await _db.update(_db.savingsGoalEntries).replace(entry);
  }

  Future<void> addContribution(String goalId, double amount) async {
    final goal = await getById(goalId);
    if (goal == null) return;

    final newAmount = goal.currentAmount + amount;
    final isCompleted = newAmount >= goal.targetAmount;

    await (_db.update(_db.savingsGoalEntries)
          ..where((g) => g.id.equals(goalId)))
        .write(SavingsGoalEntriesCompanion(
          currentAmount: Value(newAmount),
          isCompleted: Value(isCompleted),
        ));
  }

  Future<void> markComplete(String goalId) async {
    await (_db.update(_db.savingsGoalEntries)
          ..where((g) => g.id.equals(goalId)))
        .write(const SavingsGoalEntriesCompanion(
          isCompleted: Value(true),
        ));
  }

  Future<void> togglePause(String goalId) async {
    final goal = await getById(goalId);
    if (goal == null) return;
    await (_db.update(_db.savingsGoalEntries)
          ..where((g) => g.id.equals(goalId)))
        .write(SavingsGoalEntriesCompanion(
          isPaused: Value(!goal.isPaused),
        ));
  }

  Future<void> deleteById(String id) async {
    await (_db.delete(_db.savingsGoalEntries)
          ..where((g) => g.id.equals(id)))
        .go();
  }

  Future<void> deleteAll() => _db.delete(_db.savingsGoalEntries).go();

  // --- Read ---

  Future<List<SavingsGoalEntry>> getAll() {
    return (_db.select(_db.savingsGoalEntries)
          ..orderBy([(g) => OrderingTerm.asc(g.deadline)]))
        .get();
  }

  Future<List<SavingsGoalEntry>> getActive() {
    return (_db.select(_db.savingsGoalEntries)
          ..where((g) =>
              g.isCompleted.equals(false) & g.isPaused.equals(false))
          ..orderBy([(g) => OrderingTerm.asc(g.deadline)]))
        .get();
  }

  Future<SavingsGoalEntry?> getById(String id) {
    return (_db.select(_db.savingsGoalEntries)
          ..where((g) => g.id.equals(id)))
        .getSingleOrNull();
  }

  Stream<List<SavingsGoalEntry>> watchAll() {
    return (_db.select(_db.savingsGoalEntries)
          ..orderBy([(g) => OrderingTerm.asc(g.deadline)]))
        .watch();
  }

  Stream<List<SavingsGoalEntry>> watchActive() {
    return (_db.select(_db.savingsGoalEntries)
          ..where((g) =>
              g.isCompleted.equals(false) & g.isPaused.equals(false))
          ..orderBy([(g) => OrderingTerm.asc(g.deadline)]))
        .watch();
  }

  // --- Calculations ---

  /// Suggested weekly contribution to reach goal on time.
  double weeklyContributionNeeded(SavingsGoalEntry goal) {
    final remaining = goal.targetAmount - goal.currentAmount;
    if (remaining <= 0) return 0;
    final daysLeft =
        goal.deadline.difference(DateTime.now()).inDays;
    if (daysLeft <= 0) return remaining;
    final weeksLeft = daysLeft / 7;
    return remaining / weeksLeft;
  }
}
