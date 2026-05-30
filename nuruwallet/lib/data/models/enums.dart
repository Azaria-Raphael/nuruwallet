// All enumerations used throughout NuruWallet.
// Stored as integers in Drift tables via intEnum<T>().
// IMPORTANT: never reorder these values — the integer ordinals are persisted in the database.
// Only append new values at the end.

enum TransactionType {
  expense, // index 0
  income,  // index 1
}

enum AccountType {
  cash,         // index 0
  mobileMoney,  // index 1
  bank,         // index 2
  savings,      // index 3
}

enum BudgetPeriod {
  monthly, // index 0
  weekly,  // index 1
}

enum ThemeMode {
  system,  // index 0
  light,   // index 1
  dark,    // index 2
}

extension TransactionTypeX on TransactionType {
  bool get isExpense => this == TransactionType.expense;
  bool get isIncome => this == TransactionType.income;

  String get label => switch (this) {
        TransactionType.expense => 'Expense',
        TransactionType.income => 'Income',
      };
}

extension AccountTypeX on AccountType {
  String get label => switch (this) {
        AccountType.cash => 'Cash',
        AccountType.mobileMoney => 'Mobile Money',
        AccountType.bank => 'Bank',
        AccountType.savings => 'Savings',
      };

  String get iconName => switch (this) {
        AccountType.cash => 'wallet',
        AccountType.mobileMoney => 'phone',
        AccountType.bank => 'bank',
        AccountType.savings => 'piggy_bank',
      };
}
