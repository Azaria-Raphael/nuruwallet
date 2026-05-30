import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

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
                  title: const Text('PIN Lock'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.fingerprint),
                  title: const Text(AppStrings.enableBiometric),
                  trailing: Switch(value: false, onChanged: (_) {}),
                ),
              ],
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
                  leading: const Icon(Icons.cloud_upload_outlined),
                  title: const Text(AppStrings.cloudBackup),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.download_outlined),
                  title: const Text(AppStrings.exportData),
                  onTap: () {},
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
                  onTap: () {},
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
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Developer'),
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
    applicationLegalese: '© 2026 Raphael Timothy Azaria · Tanzania',
    // This adds your branded container to the top of the license page
    applicationIcon: Container(
      width: 48,
      height: 48,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF14B8A6), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Text(
          'N',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ),
  ),
),
stTile(
               ListTile(
  leading: const Icon(Icons.article_outlined),
  title: const Text('Open Source Licenses'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () => showLicensePage(
    context: context,
    applicationName: AppStrings.appName,
    applicationVersion: '1.0.0',
    applicationLegalese: '© 2026 Raphael Timothy Azaria · Tanzania',
    // This adds your branded container to the top of the license page
    applicationIcon: Container(
      width: 48,
      height: 48,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF14B8A6), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Text(
          'N',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ),
  ),
),
leading: const Icon(Icons.article_outlined),
               ListTile(
  leading: const Icon(Icons.article_outlined),
  title: const Text('Open Source Licenses'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () => showLicensePage(
    context: context,
    applicationName: AppStrings.appName,
    applicationVersion: '1.0.0',
    applicationLegalese: '© 2026 Raphael Timothy Azaria · Tanzania',
    // This adds your branded container to the top of the license page
    applicationIcon: Container(
      width: 48,
      height: 48,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF14B8A6), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Text(
          'N',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ),
  ),
),
title: const Text('Open Source Licenses'),
               ListTile(
  leading: const Icon(Icons.article_outlined),
  title: const Text('Open Source Licenses'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () => showLicensePage(
    context: context,
    applicationName: AppStrings.appName,
    applicationVersion: '1.0.0',
    applicationLegalese: '© 2026 Raphael Timothy Azaria · Tanzania',
    // This adds your branded container to the top of the license page
    applicationIcon: Container(
      width: 48,
      height: 48,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF14B8A6), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Text(
          'N',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ),
  ),
),
trailing: const Icon(Icons.chevron_right),
               ListTile(
  leading: const Icon(Icons.article_outlined),
  title: const Text('Open Source Licenses'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () => showLicensePage(
    context: context,
    applicationName: AppStrings.appName,
    applicationVersion: '1.0.0',
    applicationLegalese: '© 2026 Raphael Timothy Azaria · Tanzania',
    // This adds your branded container to the top of the license page
    applicationIcon: Container(
      width: 48,
      height: 48,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF14B8A6), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Text(
          'N',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ),
  ),
),
onTap: () => showLicensePage(
               ListTile(
  leading: const Icon(Icons.article_outlined),
  title: const Text('Open Source Licenses'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () => showLicensePage(
    context: context,
    applicationName: AppStrings.appName,
    applicationVersion: '1.0.0',
    applicationLegalese: '© 2026 Raphael Timothy Azaria · Tanzania',
    // This adds your branded container to the top of the license page
    applicationIcon: Container(
      width: 48,
      height: 48,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF14B8A6), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Text(
          'N',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ),
  ),
),
  context: context,
               ListTile(
  leading: const Icon(Icons.article_outlined),
  title: const Text('Open Source Licenses'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () => showLicensePage(
    context: context,
    applicationName: AppStrings.appName,
    applicationVersion: '1.0.0',
    applicationLegalese: '© 2026 Raphael Timothy Azaria · Tanzania',
    // This adds your branded container to the top of the license page
    applicationIcon: Container(
      width: 48,
      height: 48,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF14B8A6), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Text(
          'N',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ),
  ),
),
  applicationName: AppStrings.appName,
               ListTile(
  leading: const Icon(Icons.article_outlined),
  title: const Text('Open Source Licenses'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () => showLicensePage(
    context: context,
    applicationName: AppStrings.appName,
    applicationVersion: '1.0.0',
    applicationLegalese: '© 2026 Raphael Timothy Azaria · Tanzania',
    // This adds your branded container to the top of the license page
    applicationIcon: Container(
      width: 48,
      height: 48,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF14B8A6), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Text(
          'N',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ),
  ),
),
  applicationVersion: '1.0.0',
               ListTile(
  leading: const Icon(Icons.article_outlined),
  title: const Text('Open Source Licenses'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () => showLicensePage(
    context: context,
    applicationName: AppStrings.appName,
    applicationVersion: '1.0.0',
    applicationLegalese: '© 2026 Raphael Timothy Azaria · Tanzania',
    // This adds your branded container to the top of the license page
    applicationIcon: Container(
      width: 48,
      height: 48,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF14B8A6), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Text(
          'N',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ),
  ),
),
  applicationLegalese:
               ListTile(
  leading: const Icon(Icons.article_outlined),
  title: const Text('Open Source Licenses'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () => showLicensePage(
    context: context,
    applicationName: AppStrings.appName,
    applicationVersion: '1.0.0',
    applicationLegalese: '© 2026 Raphael Timothy Azaria · Tanzania',
    // This adds your branded container to the top of the license page
    applicationIcon: Container(
      width: 48,
      height: 48,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF14B8A6), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Text(
          'N',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ),
  ),
),
      '© 2026 Raphael Timothy Azaria · Tanzania',
               ListTile(
  leading: const Icon(Icons.article_outlined),
  title: const Text('Open Source Licenses'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () => showLicensePage(
    context: context,
    applicationName: AppStrings.appName,
    applicationVersion: '1.0.0',
    applicationLegalese: '© 2026 Raphael Timothy Azaria · Tanzania',
    // This adds your branded container to the top of the license page
    applicationIcon: Container(
      width: 48,
      height: 48,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF14B8A6), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Text(
          'N',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ),
  ),
),
),
               ListTile(
  leading: const Icon(Icons.article_outlined),
  title: const Text('Open Source Licenses'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () => showLicensePage(
    context: context,
    applicationName: AppStrings.appName,
    applicationVersion: '1.0.0',
    applicationLegalese: '© 2026 Raphael Timothy Azaria · Tanzania',
    // This adds your branded container to the top of the license page
    applicationIcon: Container(
      width: 48,
      height: 48,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF14B8A6), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Text(
          'N',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
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