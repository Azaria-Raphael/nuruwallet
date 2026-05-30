import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/goal_icon.dart';
import '../../../data/database/app_database.dart';
import '../../../data/providers/repository_providers.dart';

void showContributionSheet(BuildContext context, SavingsGoalEntry goal) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => ContributionSheet(goal: goal),
  );
}

class ContributionSheet extends ConsumerStatefulWidget {
  const ContributionSheet({super.key, required this.goal});

  final SavingsGoalEntry goal;

  @override
  ConsumerState<ContributionSheet> createState() =>
      _ContributionSheetState();
}

class _ContributionSheetState extends ConsumerState<ContributionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _saving = false;

  SavingsGoalEntry get goal => widget.goal;

  double get _weeklyNeeded {
    final remaining = goal.targetAmount - goal.currentAmount;
    if (remaining <= 0) return 0;
    final daysLeft = goal.deadline.difference(DateTime.now()).inDays;
    if (daysLeft <= 0) return remaining;
    return remaining / (daysLeft / 7);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final amount =
          double.parse(_amountController.text.replaceAll(',', ''));
      await ref.read(goalRepositoryProvider).addContribution(goal.id, amount);

      if (!mounted) return;
      Navigator.pop(context);

      // Check completion after stream settles on next frame.
      final newAmount = goal.currentAmount + amount;
      if (newAmount >= goal.targetAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.goalCompleted} "${goal.name}" reached its target!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.income,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress =
        (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
    final remaining = goal.targetAmount - goal.currentAmount;

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primaryContainer,
                  child: Icon(GoalIcon.get(goal.iconName),
                      color: AppColors.primary, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    goal.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress summary
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        CurrencyFormatter.format(goal.currentAmount),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%  of  ${CurrencyFormatter.formatCompact(goal.targetAmount)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Amount field
                  TextFormField(
                    controller: _amountController,
                    autofocus: true,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                    ],
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                    decoration: const InputDecoration(
                      labelText: 'Amount to add',
                      prefixText: 'TZS  ',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return AppStrings.errorAmountRequired;
                      }
                      final n = double.tryParse(v.replaceAll(',', ''));
                      if (n == null || n <= 0) {
                        return AppStrings.errorAmountInvalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Weekly hint
                  if (_weeklyNeeded > 0)
                    Text(
                      'Still need ${CurrencyFormatter.formatCompact(remaining)} · '
                      '${CurrencyFormatter.formatCompact(_weeklyNeeded)}/week to stay on track',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              AppStrings.addContribution,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
