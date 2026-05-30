import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_strings.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/pin_screen.dart';
import 'features/analytics/screens/analytics_screen.dart';
import 'features/budget/screens/budget_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/goals/screens/goals_screen.dart';
import 'features/transactions/screens/transactions_screen.dart';

class NuruWalletApp extends ConsumerWidget {
  const NuruWalletApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      home: Consumer(
        builder: (ctx, r, _) {
          final auth = r.watch(authProvider);
          if (auth.isPinSet && !auth.sessionUnlocked) {
            return const PinScreen(mode: PinMode.verify);
          }
          return const _MainShell();
        },
      ),
    );
  }
}

class _MainShell extends ConsumerStatefulWidget {
  const _MainShell();

  @override
  ConsumerState<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<_MainShell>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  DateTime? _pausedAt;

  // Lock the app after 30 s in background.
  static const _lockThreshold = Duration(seconds: 30);

  static const _screens = [
    DashboardScreen(),
    TransactionsScreen(),
    BudgetScreen(),
    GoalsScreen(),
    AnalyticsScreen(),
  ];

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: AppStrings.navHome,
    ),
    NavigationDestination(
      icon: Icon(Icons.receipt_long_outlined),
      selectedIcon: Icon(Icons.receipt_long),
      label: AppStrings.navTransactions,
    ),
    NavigationDestination(
      icon: Icon(Icons.account_balance_wallet_outlined),
      selectedIcon: Icon(Icons.account_balance_wallet),
      label: AppStrings.navBudget,
    ),
    NavigationDestination(
      icon: Icon(Icons.savings_outlined),
      selectedIcon: Icon(Icons.savings),
      label: AppStrings.navGoals,
    ),
    NavigationDestination(
      icon: Icon(Icons.bar_chart_outlined),
      selectedIcon: Icon(Icons.bar_chart),
      label: AppStrings.navAnalytics,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pausedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final paused = _pausedAt;
      if (paused != null &&
          DateTime.now().difference(paused) >= _lockThreshold) {
        ref.read(authProvider.notifier).lock();
      }
      _pausedAt = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          Theme.of(context).brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
    ));

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) =>
            setState(() => _currentIndex = index),
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        destinations: _destinations,
      ),
    );
  }
}
