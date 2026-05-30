import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/account_icon.dart';
import '../../../core/utils/category_icon.dart';
import '../../../data/database/app_database.dart';
import '../../../data/models/enums.dart';
import '../../../data/providers/repository_providers.dart';

void showAddEditCategorySheet(
  BuildContext context, {
  CategoryEntry? category,
  TransactionType initialType = TransactionType.expense,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => AddEditCategorySheet(
      category: category,
      initialType: initialType,
    ),
  );
}

class AddEditCategorySheet extends ConsumerStatefulWidget {
  const AddEditCategorySheet({
    super.key,
    this.category,
    this.initialType = TransactionType.expense,
  });

  final CategoryEntry? category;
  final TransactionType initialType;

  @override
  ConsumerState<AddEditCategorySheet> createState() =>
      _AddEditCategorySheetState();
}

class _AddEditCategorySheetState extends ConsumerState<AddEditCategorySheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String _iconName = 'other';
  int _colorValue = accountColorOptions.first;
  String _categoryType = 'expense';
  bool _rolloverEnabled = false;
  String? _parentCategoryId;
  bool _saving = false;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    if (c != null) {
      _nameController.text = c.name;
      _iconName = c.iconName;
      _colorValue = c.colorValue;
      _categoryType = c.categoryType;
      _rolloverEnabled = c.rolloverEnabled;
      _parentCategoryId = c.parentCategoryId;
    } else {
      _categoryType =
          widget.initialType == TransactionType.income ? 'income' : 'expense';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final repo = ref.read(categoryRepositoryProvider);
      if (_isEditing) {
        await repo.update(widget.category!.copyWith(
          name: _nameController.text.trim(),
          iconName: _iconName,
          colorValue: _colorValue,
          categoryType: _categoryType,
          rolloverEnabled: _rolloverEnabled,
          parentCategoryId: Value(_parentCategoryId),
        ));
      } else {
        await repo.add(
          name: _nameController.text.trim(),
          iconName: _iconName,
          colorValue: _colorValue,
          categoryType: _categoryType,
          rolloverEnabled: _rolloverEnabled,
          parentCategoryId: _parentCategoryId,
          sortOrder: 999,
        );
      }
      if (mounted) Navigator.pop(context);
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

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
            'Delete "${widget.category!.name}"? Transactions using it will remain.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref
        .read(categoryRepositoryProvider)
        .deleteById(widget.category!.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accentColor = Color(_colorValue);
    final allCatsAsync = ref.watch(allCategoriesProvider);

    // Parent category candidates: same type, not self, not already a sub-cat
    final parentCandidates = allCatsAsync.valueOrNull
            ?.where((c) =>
                (c.categoryType == _categoryType || c.categoryType == 'both') &&
                c.id != widget.category?.id &&
                c.parentCategoryId == null)
            .toList() ??
        [];

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text(
                  _isEditing ? 'Edit Category' : 'New Category',
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
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Category Name',
                        prefixIcon: Icon(
                          CategoryIcon.get(_iconName),
                          color: accentColor,
                        ),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Please enter a name.'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // Type (expense / income)
                    _Label('Type'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _TypeChip(
                          label: 'Expense',
                          color: AppColors.expense,
                          selected: _categoryType == 'expense',
                          onTap: () => setState(() {
                            _categoryType = 'expense';
                            _parentCategoryId = null;
                          }),
                        ),
                        const SizedBox(width: 10),
                        _TypeChip(
                          label: 'Income',
                          color: AppColors.income,
                          selected: _categoryType == 'income',
                          onTap: () => setState(() {
                            _categoryType = 'income';
                            _parentCategoryId = null;
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Icon picker
                    _Label('Icon'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: CategoryIcon.allOptions.map((opt) {
                        final sel = _iconName == opt.name;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _iconName = opt.name),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: sel
                                  ? accentColor.withValues(alpha: 0.15)
                                  : scheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: sel
                                    ? accentColor
                                    : scheme.outline
                                        .withValues(alpha: 0.2),
                                width: sel ? 1.5 : 1,
                              ),
                            ),
                            child: Icon(
                              opt.icon,
                              size: 22,
                              color: sel
                                  ? accentColor
                                  : scheme.onSurface
                                      .withValues(alpha: 0.5),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Color picker
                    _Label('Color'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: accountColorOptions.map((c) {
                        final sel = _colorValue == c;
                        return GestureDetector(
                          onTap: () => setState(() => _colorValue = c),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Color(c),
                              shape: BoxShape.circle,
                              border: sel
                                  ? Border.all(
                                      color: scheme.onSurface, width: 2.5)
                                  : null,
                              boxShadow: sel
                                  ? [
                                      BoxShadow(
                                        color:
                                            Color(c).withValues(alpha: 0.5),
                                        blurRadius: 6,
                                      )
                                    ]
                                  : null,
                            ),
                            child: sel
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 16)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Budget rollover toggle
                    SwitchListTile(
                      title: const Text(
                        'Budget Rollover',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      subtitle: const Text(
                        'Unused budget carries over to next month',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: _rolloverEnabled,
                      onChanged: (v) =>
                          setState(() => _rolloverEnabled = v),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                    const SizedBox(height: 12),

                    // Parent category (only relevant for expense/income)
                    if (parentCandidates.isNotEmpty) ...[
                      _Label('Parent Category (optional)'),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String?>(
                        initialValue: _parentCategoryId,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.folder_outlined),
                          hintText: 'None (top-level)',
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('None (top-level)'),
                          ),
                          ...parentCandidates.map((c) =>
                              DropdownMenuItem<String?>(
                                value: c.id,
                                child: Text(c.name),
                              )),
                        ],
                        onChanged: (v) =>
                            setState(() => _parentCategoryId = v),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const SizedBox(height: 16),

                    if (_isEditing) ...[
                      OutlinedButton.icon(
                        onPressed: _delete,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Delete Category'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.expense,
                          side: BorderSide(
                              color: AppColors.expense
                                  .withValues(alpha: 0.5)),
                          minimumSize: const Size(double.infinity, 44),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white),
                              )
                            : Text(
                                _isEditing ? 'Save' : 'Create Category',
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

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? color
                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected
                    ? color
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
