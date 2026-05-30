import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/notification_service.dart';
import 'core/services/recurring_transaction_service.dart';
import 'core/utils/date_formatter.dart';
import 'data/providers/repository_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();

  // Seed default categories and account on first launch.
  await container.read(categoryRepositoryProvider).seedDefaultsIfEmpty();
  await container.read(categoryRepositoryProvider).seedIncomeCategoriesIfMissing();
  await container.read(accountRepositoryProvider).seedDefaultIfEmpty();
  await container.read(themeModeProvider.notifier).load();
  await container.read(authProvider.notifier).load();

  // Notifications
  await NotificationService.init();
  await NotificationService.showDailyReminderIfNeeded();

  // Goal deadline alerts (notify for active goals due within 7 days)
  try {
    final goals = await container.read(goalRepositoryProvider).getActive();
    for (final goal in goals) {
      if (goal.isCompleted) continue;
      final daysLeft = DateFormatter.daysUntil(goal.deadline);
      if (daysLeft <= 7) {
        await NotificationService.showGoalDeadlineAlert(
          goalName: goal.name,
          daysLeft: daysLeft,
          goalId: goal.id,
        );
      }
    }
  } catch (_) {
    // Non-critical startup check
  }

  // Process any overdue recurring transactions
  try {
    await RecurringTransactionService(
      transactionRepo: container.read(transactionRepositoryProvider),
      accountRepo: container.read(accountRepositoryProvider),
    ).processRecurring();
  } catch (_) {
    // Non-critical startup task
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const NuruWalletApp(),
    ),
  );
}
