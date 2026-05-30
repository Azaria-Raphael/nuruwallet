import 'dart:convert';

import 'package:drift/drift.dart';

import '../database/app_database.dart';

class ExchangeRateRepository {
  ExchangeRateRepository(this._db);

  final AppDatabase _db;

  // --- Write ---

  Future<void> saveRates({
    required String baseCurrency,
    required Map<String, double> rates,
    required String source,
  }) async {
    // Keep only the latest entry — delete old records first.
    await _db.delete(_db.exchangeRateCacheEntries).go();

    await _db.into(_db.exchangeRateCacheEntries).insert(
          ExchangeRateCacheEntriesCompanion.insert(
            baseCurrency: baseCurrency,
            ratesJson: jsonEncode(rates),
            fetchedAt: DateTime.now(),
            source: source,
          ),
        );
  }

  // --- Read ---

  Future<ExchangeRateCacheEntry?> getLatest() {
    return (_db.select(_db.exchangeRateCacheEntries)
          ..orderBy([(e) => OrderingTerm.desc(e.fetchedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<Map<String, double>> getRates() async {
    final entry = await getLatest();
    if (entry == null) return {};
    final decoded = jsonDecode(entry.ratesJson) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, (v as num).toDouble()));
  }

  Future<double?> getRate(String targetCurrency) async {
    final rates = await getRates();
    return rates[targetCurrency.toUpperCase()];
  }

  /// Returns true if rates were fetched today.
  Future<bool> isFreshToday() async {
    final entry = await getLatest();
    if (entry == null) return false;
    final today = DateTime.now();
    final fetched = entry.fetchedAt;
    return fetched.year == today.year &&
        fetched.month == today.month &&
        fetched.day == today.day;
  }

  Stream<ExchangeRateCacheEntry?> watchLatest() {
    return (_db.select(_db.exchangeRateCacheEntries)
          ..orderBy([(e) => OrderingTerm.desc(e.fetchedAt)])
          ..limit(1))
        .watchSingleOrNull();
  }
}
