import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/goal_icon.dart';
import '../../../data/database/app_database.dart';
import '../../../data/providers/repository_providers.dart';

void showAddGoalSheet(BuildContext context, {SavingsGoalEntry? goal}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => AddGoalSheet(goal: goal),
  );
}

class AddGoalSheet extends ConsumerStatefulWidget {
  const AddGoalSheet({super.key, this.goal});

  final SavingsGoalEntry? goal;

  @override
  ConsumerState<AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends ConsumerState<AddGoalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _iconName = 'savings';
  DateTime _deadline = DateTime.now().add(const Duration(days: 180));
  bool _saving = false;

  bool get _isEditing => widget.goal != null;

  @override
  void initState() {
    super.initState();
    final g = widget.goal;
    if (g != null) {
      _nameController.text = g.name;
      final a = g.targetAmount;
      _amountController.text =
          a % 1 == 0 ? a.toInt().toString() : a.toString();
      _noteController.text = g.note ?? '';
      _iconName = g.iconName;
      _deadline = g.deadline;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final repo = ref.read(goalRepositoryProvider);
      final note = _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim();
      final targetAmount =
          double.parse(_amountController.text.replaceAll(',', ''));

      if (_isEditing) {
        await repo.update(widget.goal!.copyWith(
          name: _nameController.text.trim(),
          targetAmount: targetAmount,
          iconName: _iconName,
          deadline: _deadline,
          note: Value(note),
        ));
      } else {
        await repo.add(
          name: _nameController.text.trim(),
          iconName: _iconName,
          targetAmount: targetAmount,
          deadline: _deadline,
          note: note,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save goal: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null && mounted) setState(() => _deadline = picked);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                color:
                    colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text(
                  _isEditing ? 'Edit Goal' : AppStrings.addGoal,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    TextFormField(
                      controller: _nameController,
                      autofocus: !_isEditing,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: AppStrings.goalName,
                        hintText: 'e.g. New Laptop, Emergency Fund',
                        prefixIcon:
                            const Icon(Icons.flag_outlined),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty
                              ? 'Please enter a goal name.'
                              : null,
                    ),
                    const SizedBox(height: 20),

                    // Target amount
                    TextFormField(
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                              decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[\d.,]')),
                      ],
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      decoration: const InputDecoration(
                        labelText: AppStrings.targetAmount,
                        prefixText: 'TZS  ',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return AppStrings.errorAmountRequired;
                        }
                        final n = double.tryParse(
                            v.replaceAll(',', ''));
                        if (n == null || n <= 0) {
                          return AppStrings.errorAmountInvalid;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Deadline
                    _Label(AppStrings.deadline),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _pickDeadline,
                      icon: const Icon(
                          Icons.calendar_today_outlined,
                          size: 18),
                      label: Text(DateFormatter.full(_deadline)),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Icon picker
                    _Label('Icon'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: GoalIcon.options.map((opt) {
                        final selected = _iconName == opt.name;
                        return _IconChip(
                          option: opt,
                          selected: selected,
                          onTap: () =>
                              setState(() => _iconName = opt.name),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Note
                    TextFormField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        labelText: 'Note (optional)',
                        hintText: 'e.g. Save TZS 5,000 weekly',
                        prefixIcon:
                            const Icon(Icons.notes_outlined),
                      ),
                      minLines: 1,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 28),

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
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _isEditing
                                    ? AppStrings.save
                                    : 'Create Goal',
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
          ),
        ],
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip(
      {required this.option,
      required this.selected,
      required this.onTap});
  final GoalIconOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primaryContainer
              : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? scheme.primary
                : scheme.outline.withValues(alpha: 0.2),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              option.icon,
              size: 16,
              color: selected
                  ? scheme.onPrimaryContainer
                  : scheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 6),
            Text(
              option.label,
              style: TextStyle(
                fontSize: 12,
                color: selected
                    ? scheme.onPrimaryContainer
                    : scheme.onSurface.withValues(alpha: 0.7),
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.7),
          ),
    );
  }
}
