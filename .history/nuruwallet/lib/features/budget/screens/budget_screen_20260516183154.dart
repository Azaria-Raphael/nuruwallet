import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/category_icon.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/database/app_database.dart';
import '../../../data/providers/repository_providers.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(expenseCategoriesProvider);
    final spendingAsync = ref.watch(currentMonthSpendingProvider);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Planner'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                DateFormatter.monthYear(now),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
      body: categoriesAsync.when(
        data: (categories) {
          final spending = spendingAsync.valueOrNull ?? {};
          final budgetedCats = categories
              .where((c) => c.monthlyLimit > 0)
              .toList();
          final totalBudget = budgetedCats.fold<double>(
            0,
            (s, c) => s + c.monthlyLimit,
          );
          final totalBudgetedSpent = budgetedCats.fold<double>(
            0,
            (s, c) => s + (spending[c.id] ?? 0),
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (budgetedCats.isNotEmpty) ...[
                _SummaryCard(
                  totalBudget: totalBudget,
                  totalSpent: totalBudgetedSpent,
                ),
                const SizedBox(height: 16),
              ] else ...[
                const _EmptyBudgetHint(),
                const SizedBox(height: 16),
              ],
              for (final cat in categories) ...[
                _CategoryBudgetCard(
                  key: ValueKey(cat.id),
                  category: cat,
                  spent: spending[cat.id] ?? 0,
                ),
                const SizedBox(height: 8),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _SummaryCard
// ---------------------------------------------------------------------------

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.totalBudget, required this.totalSpent});

  final double totalBudget;
  final double totalSpent;

  @override
  Widget build(BuildContext context) {
    final progress = totalBudget > 0
        ? (totalSpent / totalBudget).clamp(0.0, 1.0)
        : 0.0;
    final remaining = totalBudget - totalSpent;
    final isOver = totalSpent > totalBudget;
    final progressColor = isOver
        ? AppColors.budgetOver
        : progress >= 0.8
        ? AppColors.budgetDanger
        : progress >= 0.6
        ? AppColors.budgetWarning
        : AppColors.budgetSafe;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.budgetProgress,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: progressColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: progressColor.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatChip(
                  label: 'Spent',
                  value: CurrencyFormatter.formatCompact(totalSpent),
                  color: progressColor,
                ),
                _StatChip(
                  label: 'Budget',
                  value: CurrencyFormatter.formatCompact(totalBudget),
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                _StatChip(
                  label: isOver ? 'Over by' : 'Remaining',
                  value: CurrencyFormatter.formatCompact(remaining.abs()),
                  color: isOver ? AppColors.budgetOver : AppColors.budgetSafe,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class _EmptyBudgetHint extends StatelessWidget {
  const _EmptyBudgetHint();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tap any category below to set a monthly spending limit.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _CategoryBudgetCard
// ---------------------------------------------------------------------------

class _CategoryBudgetCard extends ConsumerWidget {
  const _CategoryBudgetCard({
    super.key,
    required this.category,
    required this.spent,
  });

  final CategoryEntry category;
  final double spent;

  Future<void> _showSetLimitDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => _BudgetDialogContent(category: category),
    );

    if (!context.mounted) return;
    if (result == null) return;

    await ref
        .read(categoryRepositoryProvider)
        .setMonthlyLimit(category.id, result);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cat = category;
    final limit = cat.monthlyLimit;
    final hasLimit = limit > 0;
    final progress = hasLimit ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final isOver = hasLimit && spent > limit;
    final catColor = Color(cat.colorValue);

    Color progressColor;
    if (!hasLimit || progress < 0.6) {
      progressColor = AppColors.budgetSafe;
    } else if (progress < 0.8) {
      progressColor = AppColors.budgetWarning;
    } else if (progress <= 1.0) {
      progressColor = AppColors.budgetDanger;
    } else {
      progressColor = AppColors.budgetOver;
    }

    return Card(
      child: InkWell(
        onTap: () => _showSetLimitDialog(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: catColor.withValues(alpha: 0.15),
                    child: Icon(
                      CategoryIcon.get(cat.iconName),
                      color: catColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      cat.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isOver)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.budgetOver.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Over',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.budgetOver,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    Text(
                      hasLimit
                          ? '${CurrencyFormatter.formatCompact(spent)} / ${CurrencyFormatter.formatCompact(limit)}'
                          : spent > 0
                          ? CurrencyFormatter.formatCompact(spent)
                          : 'Tap to set budget',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface
                            .withValues(
                              alpha: hasLimit || spent > 0 ? 0.6 : 0.4,
                            ),
                        fontStyle: hasLimit || spent > 0
                            ? FontStyle.normal
                            : FontStyle.italic,
                      ),
                    ),
                ],
              ),
              if (hasLimit) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: progressColor.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
              ] else if (spent > 0) ...[
                const SizedBox(height: 6),
                Text(
                  'No limit set — tap to add one',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.4),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Standalone Stateful Widget for Dialog Content (Prevents Controller Crash)
// ---------------------------------------------------------------------------

class _BudgetDialogContent extends StatefulWidget {
  final CategoryEntry category;

  const _BudgetDialogContent({required this.category});

  @override
  State<_BudgetDialogContent> createState() => _BudgetDialogContentState();
}

class _BudgetDialogContentState extends State<_BudgetDialogContent> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.category.monthlyLimit > 0
          ? widget.category.monthlyLimit.toInt().toString()
          : '',
    );
  }

  @override
  void dispose() {
    _controller
        .dispose(); // Safely fires only after the dialog finishes unmounting
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Budget for ${widget.category.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set the maximum you want to spend on ${widget.category.name} this month.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            ],
            decoration: const InputDecoration(
              labelText: 'Monthly limit',
              prefixText: 'TZS  ',
              hintText: 'Enter 0 to remove limit',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        if (widget.category.monthlyLimit > 0)
          TextButton(
            onPressed: () => Navigator.pop(context, 0.0),
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: const Text('Remove'),
          ),
        FilledButton(
          onPressed: () {
            final v = double.tryParse(_controller.text.trim()) ?? 0.0;
            Navigator.pop(context, v);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
