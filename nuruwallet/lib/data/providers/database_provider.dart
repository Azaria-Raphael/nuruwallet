import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';

/// Single shared AppDatabase instance for the entire app.
/// Drift opens the SQLite file lazily on first query — no async init needed.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
