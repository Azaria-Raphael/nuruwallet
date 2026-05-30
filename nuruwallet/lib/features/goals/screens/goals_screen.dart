import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/goal_icon.dart';
import '../../../data/database/app_database.dart';
import '../../../data/providers/repository_providers.dart';
import '../widgets/add_goal_sheet.dart';
import '../widgets/contribution_sheet.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(allGoalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.savingsGoals)),
      body: goalsAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.savings_outlined,
                    size: 64,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No savings goals yet',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to create your first goal',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.4),
                        ),
                  ),
                ],
              ),
            );
          }

          final active = goals
              .where((g) => !g.isCompleted && !g.isPaused)
              .toList();
          final paused =
              goals.where((g) => !g.isCompleted && g.isPaused).toList();
          final completed =
              goals.where((g) => g.isCompleted).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (active.isNotEmpty) ...[
                for (final g in active) ...[
                  _GoalCard(
                    goal: g,
                    onContribute: () =>
                        showContributionSheet(context, g),
                    onEdit: () =>
                        showAddGoalSheet(context, goal: g),
                    onPause: () => ref
                        .read(goalRepositoryProvider)
                        .togglePause(g.id),
                    onDelete: () =>
                        _confirmDelete(context, ref, g),
                    onComplete: () =>
                        _confirmComplete(context, ref, g),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
              if (paused.isNotEmpty) ...[
                _SectionHeader('Paused'),
                const SizedBox(height: 8),
                for (final g in paused) ...[
                  _GoalCard(
                    goal: g,
                    onContribute: () =>
                        showContributionSheet(context, g),
                    onEdit: () =>
                        showAddGoalSheet(context, goal: g),
                    onPause: () => ref
                        .read(goalRepositoryProvider)
                        .togglePause(g.id),
                    onDelete: () =>
                        _confirmDelete(context, ref, g),
                    onComplete: () =>
                        _confirmComplete(context, ref, g),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
              if (completed.isNotEmpty) ...[
                _SectionHeader('Completed'),
                const SizedBox(height: 8),
                for (final g in completed) ...[
                  _CompletedGoalCard(
                    goal: g,
                    onDelete: () =>
                        _confirmDelete(context, ref, g),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddGoalSheet(context),
        tooltip: AppStrings.addGoal,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmComplete(
    BuildContext context,
    WidgetRef ref,
    SavingsGoalEntry goal,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark as Complete?'),
        content: Text(
            'Congratulations! Mark "${goal.name}" as achieved?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not Yet'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.income),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(goalRepositoryProvider).markComplete(goal.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${goal.name}" achieved!'),
            backgroundColor: AppColors.income,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    SavingsGoalEntry goal,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text(
            'Delete "${goal.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
                foregroundColor: AppColors.expense),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(goalRepositoryProvider).deleteById(goal.id);
    }
  }
}

// ---------------------------------------------------------------------------

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.onContribute,
    required this.onEdit,
    required this.onPause,
    required this.onDelete,
    required this.onComplete,
  });

  final SavingsGoalEntry goal;
  final VoidCallback onContribute;
  final VoidCallback onEdit;
  final VoidCallback onPause;
  final VoidCallback onDelete;
  final VoidCallback onComplete;

  int get _daysLeft =>
      goal.deadline.difference(DateTime.now()).inDays;

  double get _weeklyNeeded {
    final remaining = goal.targetAmount - goal.currentAmount;
    if (remaining <= 0) return 0;
    final days = _daysLeft;
    if (days <= 0) return remaining;
    return remaining / (days / 7).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
    final days = _daysLeft;
    final isPaused = goal.isPaused;
    final scheme = Theme.of(context).colorScheme;

    String deadlineLabel;
    Color deadlineColor;
    if (days < 0) {
      deadlineLabel = 'Overdue by ${-days} days';
      deadlineColor = AppColors.expense;
    } else if (days == 0) {
      deadlineLabel = 'Due today';
      deadlineColor = AppColors.budgetDanger;
    } else if (days <= 7) {
      deadlineLabel = '$days days left';
      deadlineColor = AppColors.budgetWarning;
    } else {
      deadlineLabel = '$days days left';
      deadlineColor = scheme.onSurface.withValues(alpha: 0.5);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isPaused
                      ? scheme.onSurface.withValues(alpha: 0.1)
                      : AppColors.primaryContainer,
                  child: Icon(
                    GoalIcon.get(goal.iconName),
                    color: isPaused
                        ? scheme.onSurface.withValues(alpha: 0.4)
                        : AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              goal.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: isPaused
                                    ? scheme.onSurface
                                        .withValues(alpha: 0.5)
                                    : null,
                              ),
                            ),
                          ),
                          if (isPaused)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: scheme.onSurface
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Paused',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: scheme.onSurface
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        deadlineLabel,
                        style: TextStyle(
                            fontSize: 12, color: deadlineColor),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'pause') onPause();
                    if (v == 'complete') onComplete();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'pause',
                      child: Row(children: [
                        Icon(
                          isPaused
                              ? Icons.play_arrow_outlined
                              : Icons.pause_outlined,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(isPaused ? 'Resume' : 'Pause'),
                      ]),
                    ),
                    if (progress >= 1.0)
                      PopupMenuItem(
                        value: 'complete',
                        child: Row(children: [
                          Icon(Icons.check_circle_outline,
                              size: 18, color: AppColors.income),
                          const SizedBox(width: 8),
                          Text('Mark Complete',
                              style:
                                  TextStyle(color: AppColors.income)),
                        ]),
                      ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline,
                            size: 18, color: AppColors.expense),
                        const SizedBox(width: 8),
                        Text(AppStrings.delete,
                            style: TextStyle(
                                color: AppColors.expense)),
                      ]),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isPaused
                      ? scheme.onSurface.withValues(alpha: 0.3)
                      : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CurrencyFormatter.format(goal.currentAmount),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isPaused
                        ? scheme.onSurface.withValues(alpha: 0.4)
                        : AppColors.primary,
                  ),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}% of ${CurrencyFormatter.formatCompact(goal.targetAmount)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            if (goal.note != null && goal.note!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                goal.note!,
                style: TextStyle(
                  fontSize: 12,
                  color: isPaused
                      ? scheme.onSurface.withValues(alpha: 0.35)
                      : scheme.onSurface.withValues(alpha: 0.55),
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (!isPaused && _weeklyNeeded > 0) ...[
              const SizedBox(height: 6),
              Text(
                '${CurrencyFormatter.formatCompact(_weeklyNeeded)}/week to stay on track',
                style: TextStyle(
                  fontSize: 11,
                  color: scheme.onSurface.withValues(alpha: 0.45),
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (!isPaused) ...[
              const SizedBox(height: 12),
              if (progress >= 1.0)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onComplete,
                    icon: const Icon(Icons.check_circle_outline,
                        size: 16),
                    label: const Text('Mark as Complete'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.income,
                      foregroundColor: Colors.white,
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onContribute,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text(AppStrings.addContribution),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CompletedGoalCard extends StatelessWidget {
  const _CompletedGoalCard(
      {required this.goal, required this.onDelete});

  final SavingsGoalEntry goal;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor:
                  AppColors.income.withValues(alpha: 0.15),
              child: Icon(GoalIcon.get(goal.iconName),
                  color: AppColors.income, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  Text(
                    CurrencyFormatter.format(goal.targetAmount),
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.check_circle,
                color: AppColors.income, size: 22),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete_outline,
                        size: 18, color: AppColors.expense),
                    const SizedBox(width: 8),
                    Text(AppStrings.delete,
                        style: TextStyle(color: AppColors.expense)),
                  ]),
                ),
              ],
              icon: const Icon(Icons.more_vert, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.5),
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
