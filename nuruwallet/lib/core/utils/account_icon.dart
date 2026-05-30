import 'package:flutter/material.dart';

import '../../data/models/enums.dart';

abstract final class AccountIcon {
  static IconData get(AccountType type) => switch (type) {
        AccountType.cash => Icons.account_balance_wallet,
        AccountType.mobileMoney => Icons.phone_android,
        AccountType.bank => Icons.account_balance,
        AccountType.savings => Icons.savings,
      };

  static String label(AccountType type) => switch (type) {
        AccountType.cash => 'Cash',
        AccountType.mobileMoney => 'Mobile Money',
        AccountType.bank => 'Bank',
        AccountType.savings => 'Savings',
      };
}

const accountColorOptions = <int>[
  0xFF0D9488, // teal (brand default)
  0xFF3B82F6, // blue
  0xFF8B5CF6, // purple
  0xFFEC4899, // pink
  0xFFF59E0B, // amber
  0xFF10B981, // emerald
  0xFFEF4444, // red
  0xFF6B7280, // slate
];
