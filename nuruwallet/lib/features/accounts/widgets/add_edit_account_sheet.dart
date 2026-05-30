import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/account_icon.dart';
import '../../../data/database/app_database.dart';
import '../../../data/models/enums.dart';
import '../../../data/providers/repository_providers.dart';
import 'transfer_sheet.dart';

void showAddEditAccountSheet(
  BuildContext context, {
  AccountEntry? account,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => AddEditAccountSheet(account: account),
  );
}

class AddEditAccountSheet extends ConsumerStatefulWidget {
  const AddEditAccountSheet({super.key, this.account});

  final AccountEntry? account;

  @override
  ConsumerState<AddEditAccountSheet> createState() =>
      _AddEditAccountSheetState();
}

class _AddEditAccountSheetState
    extends ConsumerState<AddEditAccountSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();

  AccountType _type = AccountType.cash;
  int _colorValue = accountColorOptions.first;
  bool _saving = false;

  bool get _isEditing => widget.account != null;

  @override
  void initState() {
    super.initState();
    final a = widget.account;
    if (a != null) {
      _nameController.text = a.name;
      _type = a.type;
      _colorValue = a.colorValue;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final repo = ref.read(accountRepositoryProvider);
      if (_isEditing) {
        await repo.update(widget.account!.copyWith(
          name: _nameController.text.trim(),
          type: _type,
          colorValue: _colorValue,
        ));
      } else {
        final initialBalance = double.tryParse(
                _balanceController.text.replaceAll(',', '')) ??
            0.0;
        await repo.add(
          name: _nameController.text.trim(),
          type: _type,
          colorValue: _colorValue,
          balance: initialBalance,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Could not save: $e'),
              behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final allAccounts =
        await ref.read(accountRepositoryProvider).getAll();
    if (!mounted) return;
    if (allAccounts.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Can't delete your only account."),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text(
          'Delete "${widget.account!.name}"? '
          'Transactions recorded to this account will remain but no longer link to it.',
        ),
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

    if (confirmed != true || !mounted) return;

    final account = widget.account!;
    final repo = ref.read(accountRepositoryProvider);

    if (account.isDefault) {
      final others =
          allAccounts.where((a) => a.id != account.id).toList();
      if (others.isNotEmpty) {
        await repo.update(others.first.copyWith(isDefault: true));
      }
    }
    await repo.deleteById(account.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = Color(_colorValue);

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
                Text(
                  _isEditing
                      ? 'Edit Account'
                      : AppStrings.addAccount,
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
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Account Name',
                        prefixIcon: Icon(
                          AccountIcon.get(_type),
                          color: accentColor,
                        ),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty
                              ? 'Please enter an account name.'
                              : null,
                    ),
                    const SizedBox(height: 20),

                    // Type
                    _SectionLabel('Account Type'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: AccountType.values.map((t) {
                        final selected = _type == t;
                        return ChoiceChip(
                          selected: selected,
                          avatar: Icon(
                            AccountIcon.get(t),
                            size: 16,
                            color: selected
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                          ),
                          label: Text(AccountIcon.label(t)),
                          onSelected: (_) =>
                              setState(() => _type = t),
                          selectedColor: colorScheme.primaryContainer,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Color
                    _SectionLabel('Color'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: accountColorOptions.map((c) {
                        final isSelected = _colorValue == c;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _colorValue = c),
                          child: AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 150),
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Color(c),
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                      color: colorScheme.onSurface,
                                      width: 2)
                                  : null,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Color(c)
                                            .withValues(alpha: 0.5),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 16)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),

                    // Initial balance (add mode only)
                    if (!_isEditing) ...[
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _balanceController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                                decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[\d.,]')),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Opening Balance (optional)',
                          prefixText: 'TZS  ',
                          hintText: '0',
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // Edit-mode actions
                    if (_isEditing) ...[
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          showTransferSheet(context,
                              fromAccount: widget.account);
                        },
                        icon: const Icon(Icons.swap_horiz, size: 18),
                        label: const Text(
                            AppStrings.transferBetweenAccounts),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 44),
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: _delete,
                        icon: const Icon(Icons.delete_outline,
                            size: 18),
                        label: const Text('Delete Account'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.expense,
                          side: BorderSide(
                              color:
                                  AppColors.expense.withValues(alpha: 0.5)),
                          minimumSize: const Size(double.infinity, 44),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Save
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
                                _isEditing
                                    ? AppStrings.save
                                    : 'Add Account',
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
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
