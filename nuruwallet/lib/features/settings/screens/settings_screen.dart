import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/export_service.dart';
import '../../../data/providers/repository_providers.dart';
import '../../auth/screens/pin_screen.dart';
import '../../categories/screens/categories_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionHeader('Appearance'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text(AppStrings.theme),
              subtitle: Text(_themeLabel(themeMode)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showThemePicker(context, ref, themeMode),
            ),
          ),
          const SizedBox(height: 16),
          const _SectionHeader('Security'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outlined),
                  title: Text(authState.isPinSet ? 'Change PIN' : 'Set PIN'),
                  subtitle: Text(
                    authState.isPinSet
                        ? 'PIN lock is enabled'
                        : 'No PIN set — tap to create one',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _handlePinTap(context, ref, authState),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.fingerprint),
                  title: const Text(AppStrings.enableBiometric),
                  subtitle: !authState.isBiometricAvailable
                      ? const Text(
                          'Not available on this device',
                          style: TextStyle(fontSize: 11),
                        )
                      : !authState.isPinSet
                          ? const Text(
                              'Set a PIN first to enable biometric',
                              style: TextStyle(fontSize: 11),
                            )
                          : null,
                  trailing: Switch(
                    value: authState.isBiometricEnabled,
                    onChanged: authState.isPinSet && authState.isBiometricAvailable
                        ? (_) => ref.read(authProvider.notifier).toggleBiometric()
                        : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _SectionHeader('Categories'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.category_outlined),
              title: const Text('Manage Categories'),
              subtitle: const Text('Add, edit or delete categories'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CategoriesScreen()),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const _SectionHeader('Currency'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.currency_exchange),
              title: const Text(AppStrings.primaryCurrency),
              trailing: const Text('TZS'),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 16),
          const _SectionHeader('Data'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download_outlined),
                  title: const Text(AppStrings.exportData),
                  subtitle: const Text('Save as CSV or PDF'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _exportData(context, ref),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(
                    Icons.delete_forever_outlined,
                    color: Colors.red,
                  ),
                  title: const Text(
                    AppStrings.deleteAllData,
                    style: TextStyle(color: Colors.red),
                  ),
                  subtitle: const Text(
                    'Remove all transactions, accounts and goals',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () => _deleteAllData(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _SectionHeader('About'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outlined),
                  title: const Text(AppStrings.aboutNuruWallet),
                  subtitle: const Text('${AppStrings.version} 1.0.0'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showAboutDialog(context),
                ),
                const Divider(height: 1, indent: 56),
                const ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('Developer'),
                  subtitle: Text('2026 Raphael Timothy Azaria · Tanzania'),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.article_outlined),
                  title: const Text('Open Source Licenses'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: AppStrings.appName,
                    applicationVersion: '1.0.0',
                    applicationLegalese:
                        '© 2026 Raphael Timothy Azaria · Tanzania',
                    applicationIcon: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF14B8A6), Color(0xFF0F766E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text(
                          'N',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Export Data'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'xlsx'),
            child: const ListTile(
              leading: Icon(Icons.table_chart_outlined),
              title: Text('Excel (.xlsx)'),
              subtitle: Text('Open in Microsoft Excel or Sheets'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'pdf'),
            child: const ListTile(
              leading: Icon(Icons.picture_as_pdf_outlined),
              title: Text('PDF Report'),
              subtitle: Text('Formatted document'),
            ),
          ),
        ],
      ),
    );
    if (choice == null || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preparing export…')),
    );

    try {
      final txs = await ref.read(transactionRepositoryProvider).getAll();
      final cats = await ref.read(categoryRepositoryProvider).getAll();
      final accs = await ref.read(accountRepositoryProvider).getAll();

      if (choice == 'xlsx') {
        await ExportService.exportXlsx(
            transactions: txs, categories: cats, accounts: accs);
      } else {
        await ExportService.exportPdf(
            transactions: txs, categories: cats, accounts: accs);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export failed. Please try again.')),
        );
      }
    }
  }

  Future<void> _deleteAllData(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete All Data?'),
        content: const Text(
          'This will permanently remove all transactions, accounts, '
          'savings goals, and budget limits.\n\n'
          'Categories and your PIN will be kept.\n\n'
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await ref.read(transactionRepositoryProvider).deleteAll();
    await ref.read(goalRepositoryProvider).deleteAll();
    await ref.read(accountRepositoryProvider).deleteAll();
    await ref.read(categoryRepositoryProvider).resetAllLimits();
    await ref.read(accountRepositoryProvider).seedDefaultIfEmpty();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All data has been deleted.')),
      );
    }
  }

  Future<void> _handlePinTap(
    BuildContext context,
    WidgetRef ref,
    AuthState authState,
  ) async {
    if (!authState.isPinSet) {
      await Navigator.push<void>(
        context,
        MaterialPageRoute(
            builder: (_) => const PinScreen(mode: PinMode.setup)),
      );
      return;
    }
    if (!context.mounted) return;
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Change PIN'),
              onTap: () => Navigator.pop(ctx, 'change'),
            ),
            ListTile(
              leading: const Icon(Icons.lock_open_outlined,
                  color: Colors.red),
              title: const Text('Remove PIN',
                  style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(ctx, 'remove'),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    if (choice == 'change') {
      await Navigator.push<void>(
        context,
        MaterialPageRoute(
            builder: (_) => const PinScreen(mode: PinMode.setup)),
      );
    } else if (choice == 'remove') {
      await _confirmRemovePin(context, ref);
    }
  }

  Future<void> _confirmRemovePin(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove PIN?'),
        content: const Text(
            'Your wallet will no longer be PIN-protected.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await ref.read(authProvider.notifier).removePin();
    }
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppStrings.appName,
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF14B8A6), Color(0xFF0F766E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Text(
            'N',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
      applicationLegalese: '© 2026 Raphael Timothy Azaria · Tanzania',
      children: [
        const SizedBox(height: 12),
        const Text(
          AppStrings.tagline,
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 10),
        const Text(
          'NuruWallet is a free, offline-first personal finance app '
          'built for Tanzania. Track income and expenses, manage monthly '
          'budgets, and achieve your savings goals — all without internet.',
        ),
      ],
    );
  }

  String _themeLabel(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
        ThemeMode.system => 'System default',
      };

  Future<void> _showThemePicker(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
  ) async {
    final picked = await showDialog<ThemeMode>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Choose theme'),
        children: [
          _ThemeOption(
            label: 'Light',
            icon: Icons.light_mode_outlined,
            value: ThemeMode.light,
            selected: current == ThemeMode.light,
            onTap: () => Navigator.pop(ctx, ThemeMode.light),
          ),
          _ThemeOption(
            label: 'Dark',
            icon: Icons.dark_mode_outlined,
            value: ThemeMode.dark,
            selected: current == ThemeMode.dark,
            onTap: () => Navigator.pop(ctx, ThemeMode.dark),
          ),
          _ThemeOption(
            label: 'System default',
            icon: Icons.brightness_auto_outlined,
            value: ThemeMode.system,
            selected: current == ThemeMode.system,
            onTap: () => Navigator.pop(ctx, ThemeMode.system),
          ),
        ],
      ),
    );

    // Guard async contexts against widget destruction unmounting frames
    if (!context.mounted) return;
    if (picked != null) {
      await ref.read(themeModeProvider.notifier).set(picked);
    }
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final ThemeMode value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SimpleDialogOption(
      onPressed: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: selected ? scheme.primary : scheme.onSurface.withValues(alpha: 0.6),
            size: 22,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                color: selected ? scheme.primary : null,
              ),
            ),
          ),
          if (selected)
            Icon(Icons.check, color: scheme.primary, size: 18),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}