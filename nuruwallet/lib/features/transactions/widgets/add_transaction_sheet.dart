import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/category_icon.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/database/app_database.dart';
import '../../../data/models/enums.dart';
import '../../../data/providers/repository_providers.dart';
import '../../categories/widgets/add_edit_category_sheet.dart';

void showAddTransactionSheet(
  BuildContext context, {
  TransactionEntry? transaction,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => AddTransactionSheet(transaction: transaction),
  );
}

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key, this.transaction});

  final TransactionEntry? transaction;

  @override
  ConsumerState<AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String? _selectedCategoryId;
  String? _selectedAccountId;
  DateTime _date = DateTime.now();
  bool _isRecurring = false;
  String _recurrenceInterval = 'monthly';
  String? _receiptImagePath;
  bool _saving = false;
  bool _accountInitialized = false;

  bool get _isEditing => widget.transaction != null;

  static const _intervals = ['daily', 'weekly', 'monthly', 'yearly'];

  static String _intervalLabel(String i) => switch (i) {
        'daily' => 'Daily',
        'weekly' => 'Weekly',
        'monthly' => 'Monthly',
        'yearly' => 'Yearly',
        _ => 'Monthly',
      };

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      if (mounted) setState(() {});
    });
    final t = widget.transaction;
    if (t != null) {
      _type = t.type;
      final a = t.amount;
      _amountController.text =
          a % 1 == 0 ? a.toInt().toString() : a.toString();
      _noteController.text = t.note ?? '';
      _selectedCategoryId = t.categoryId;
      _selectedAccountId = t.accountId;
      _date = t.date;
      _isRecurring = t.isRecurring;
      _recurrenceInterval = t.recurrenceInterval ?? 'monthly';
      _receiptImagePath = t.receiptImagePath;
      _accountInitialized = true;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      _toast(AppStrings.errorCategoryRequired);
      return;
    }
    if (_selectedAccountId == null) {
      _toast('Please select an account.');
      return;
    }

    setState(() => _saving = true);
    try {
      final amount =
          double.parse(_amountController.text.replaceAll(',', ''));
      final note = _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim();
      final interval = _isRecurring ? _recurrenceInterval : null;

      final transactionRepo = ref.read(transactionRepositoryProvider);
      final accountRepo = ref.read(accountRepositoryProvider);

      if (_isEditing) {
        final old = widget.transaction!;
        await transactionRepo.update(
          old.copyWith(
            amount: amount,
            type: _type,
            categoryId: _selectedCategoryId,
            accountId: _selectedAccountId,
            date: _date,
            note: Value(note),
            isRecurring: _isRecurring,
            recurrenceInterval: Value(interval),
            receiptImagePath: Value(_receiptImagePath),
          ),
        );
        final oldReversal =
            old.type == TransactionType.income ? -old.amount : old.amount;
        await accountRepo.adjustBalance(old.accountId, oldReversal);
        final newDelta =
            _type == TransactionType.income ? amount : -amount;
        await accountRepo.adjustBalance(_selectedAccountId!, newDelta);
      } else {
        await transactionRepo.add(
          amount: amount,
          type: _type,
          categoryId: _selectedCategoryId!,
          accountId: _selectedAccountId!,
          date: _date,
          note: note,
          isRecurring: _isRecurring,
          recurrenceInterval: interval,
          receiptImagePath: _receiptImagePath,
        );
        final delta = _type == TransactionType.income ? amount : -amount;
        await accountRepo.adjustBalance(_selectedAccountId!, delta);
      }

      // Budget alert: check if this expense pushes the category over 80 %
      if (_type == TransactionType.expense) {
        _checkBudgetAlert(_selectedCategoryId!);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) _toast('Could not save: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _checkBudgetAlert(String categoryId) async {
    try {
      final repo = ref.read(transactionRepositoryProvider);
      final catRepo = ref.read(categoryRepositoryProvider);
      final now = DateTime.now();
      final spent =
          await repo.sumByCategoryForMonth(categoryId, now.year, now.month);
      final cat = await catRepo.getById(categoryId);
      if (cat == null || cat.monthlyLimit <= 0) return;
      if (spent / cat.monthlyLimit >= 0.8) {
        await NotificationService.showBudgetAlert(
          categoryName: cat.name,
          spent: spent,
          limit: cat.monthlyLimit,
        );
      }
    } catch (_) {
      // Non-critical — notification failure must not block the save flow
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    if (!mounted) return;
    setState(() {
      _date = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime?.hour ?? _date.hour,
        pickedTime?.minute ?? _date.minute,
      );
    });
  }

  Future<void> _pickReceipt() async {
    final choice = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Attach Receipt'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, ImageSource.camera),
            child: const ListTile(
              leading: Icon(Icons.camera_alt_outlined),
              title: Text('Take Photo'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, ImageSource.gallery),
            child: const ListTile(
              leading: Icon(Icons.photo_library_outlined),
              title: Text('Choose from Gallery'),
            ),
          ),
        ],
      ),
    );
    if (choice == null || !mounted) return;

    final image = await ImagePicker().pickImage(
      source: choice,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (image != null && mounted) {
      setState(() => _receiptImagePath = image.path);
    }
  }

  void _viewReceiptFullScreen(BuildContext context, String path) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ReceiptViewerPage(imagePath: path),
      ),
    );
  }

  void _onTypeChanged(TransactionType t) {
    setState(() {
      _type = t;
      _selectedCategoryId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = _type == TransactionType.expense;
    final typeColor = isExpense ? AppColors.expense : AppColors.income;
    final categoriesAsync = isExpense
        ? ref.watch(expenseCategoriesProvider)
        : ref.watch(incomeCategoriesProvider);
    final accountsAsync = ref.watch(allAccountsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final accounts = accountsAsync.valueOrNull ?? [];
    final selectedAccount =
        accounts.where((a) => a.id == _selectedAccountId).firstOrNull;
    final enteredAmount =
        double.tryParse(_amountController.text.replaceAll(',', ''));
    final showBalanceWarning = isExpense &&
        selectedAccount != null &&
        enteredAmount != null &&
        enteredAmount > selectedAccount.balance;

    accountsAsync.whenData((accounts) {
      if (!_accountInitialized && accounts.isNotEmpty) {
        _accountInitialized = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _selectedAccountId = accounts.first.id);
        });
      }
    });

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text(
                  _isEditing
                      ? AppStrings.editTransaction
                      : AppStrings.addTransaction,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
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
                    _TypeToggle(
                      selected: _type,
                      onChanged: _onTypeChanged,
                    ),
                    const SizedBox(height: 20),

                    // Amount
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[\d.,]')),
                      ],
                      autofocus: !_isEditing,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: typeColor,
                          ),
                      decoration: InputDecoration(
                        labelText: AppStrings.amount,
                        prefixText: 'TZS  ',
                        prefixStyle: TextStyle(
                          color: typeColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return AppStrings.errorAmountRequired;
                        }
                        final n = double.tryParse(
                            v.replaceAll(',', ''));
                        if (n == null || !n.isFinite || n <= 0) {
                          return AppStrings.errorAmountInvalid;
                        }
                        if (n > 9999999999) {
                          return 'Amount too large (max TZS 9,999,999,999).';
                        }
                        return null;
                      },
                    ),
                    if (showBalanceWarning)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.expense.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.expense.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded,
                                  color: AppColors.expense, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Exceeds account balance of '
                                  '${CurrencyFormatter.format(selectedAccount.balance)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.expense,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Category
                    const _SectionLabel('Category'),
                    const SizedBox(height: 10),
                    categoriesAsync.when(
                      data: (cats) => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...cats.map((cat) {
                            final selected =
                                _selectedCategoryId == cat.id;
                            final catColor = Color(cat.colorValue);
                            return FilterChip(
                              selected: selected,
                              showCheckmark: false,
                              avatar: Icon(
                                CategoryIcon.get(cat.iconName),
                                size: 15,
                                color: selected
                                    ? Colors.white
                                    : catColor,
                              ),
                              label: Text(
                                cat.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: selected
                                      ? Colors.white
                                      : colorScheme.onSurface,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                              backgroundColor:
                                  catColor.withValues(alpha: 0.08),
                              selectedColor: catColor,
                              side: BorderSide(
                                color: selected
                                    ? catColor
                                    : catColor.withValues(alpha: 0.3),
                                width: selected ? 0 : 1,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 4),
                              onSelected: (_) => setState(
                                  () => _selectedCategoryId = cat.id),
                            );
                          }),
                          ActionChip(
                            avatar: Icon(
                              Icons.add,
                              size: 15,
                              color: colorScheme.primary,
                            ),
                            label: Text(
                              'New',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.primary,
                              ),
                            ),
                            backgroundColor: Colors.transparent,
                            side: BorderSide(
                              color: colorScheme.primary
                                  .withValues(alpha: 0.4),
                            ),
                            onPressed: () {
                              showAddEditCategorySheet(
                                context,
                                initialType: _type,
                              );
                            },
                          ),
                        ],
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (e, _) => Text('$e'),
                    ),
                    const SizedBox(height: 20),

                    // Account
                    const _SectionLabel('Account'),
                    const SizedBox(height: 10),
                    accountsAsync.when(
                      data: (accounts) =>
                          DropdownButtonFormField<String>(
                        initialValue: _selectedAccountId,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                              Icons.account_balance_wallet_outlined),
                        ),
                        items: accounts
                            .map((a) => DropdownMenuItem(
                                  value: a.id,
                                  child: Text(a.name),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedAccountId = v),
                        validator: (v) => v == null
                            ? 'Please select an account.'
                            : null,
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (e, _) => Text('$e'),
                    ),
                    const SizedBox(height: 20),

                    // Date & time
                    const _SectionLabel('Date & Time'),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _pickDateTime,
                      icon: const Icon(
                          Icons.calendar_today_outlined,
                          size: 18),
                      label: Text(DateFormatter.dateTimeFull(_date)),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Note
                    TextFormField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        labelText: AppStrings.note,
                        hintText: AppStrings.noteHint,
                        prefixIcon: const Icon(Icons.notes_outlined),
                      ),
                      minLines: 1,
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 20),

                    // Recurring
                    SwitchListTile(
                      title: const Text(
                        'Recurring Transaction',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      subtitle: const Text(
                        'Automatically repeats on a schedule',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: _isRecurring,
                      onChanged: (v) =>
                          setState(() => _isRecurring = v),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                    if (_isRecurring) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _intervals.map((iv) {
                          final sel = _recurrenceInterval == iv;
                          return ChoiceChip(
                            label: Text(_intervalLabel(iv)),
                            selected: sel,
                            onSelected: (_) => setState(
                                () => _recurrenceInterval = iv),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 4),
                    ],
                    const SizedBox(height: 12),

                    // Receipt image
                    if (_receiptImagePath != null) ...[
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () => _viewReceiptFullScreen(
                                context, _receiptImagePath!),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(_receiptImagePath!),
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  height: 120,
                                  color: colorScheme.surfaceContainerHighest,
                                  child: const Center(
                                    child:
                                        Icon(Icons.broken_image_outlined),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: GestureDetector(
                              onTap: () => setState(
                                  () => _receiptImagePath = null),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 6,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.zoom_in,
                                      color: Colors.white, size: 12),
                                  SizedBox(width: 3),
                                  Text(
                                    'Tap to view',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    OutlinedButton.icon(
                      onPressed: _pickReceipt,
                      icon: Icon(
                        _receiptImagePath != null
                            ? Icons.edit_outlined
                            : Icons.attach_file_outlined,
                        size: 18,
                      ),
                      label: Text(_receiptImagePath != null
                          ? 'Change Receipt'
                          : 'Attach Receipt'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44),
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: typeColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              typeColor.withValues(alpha: 0.5),
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
                                AppStrings.save,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
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

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({required this.selected, required this.onChanged});

  final TransactionType selected;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ToggleOption(
          label: AppStrings.expense,
          icon: Icons.arrow_upward_rounded,
          color: AppColors.expense,
          selected: selected == TransactionType.expense,
          onTap: () => onChanged(TransactionType.expense),
        ),
        const SizedBox(width: 12),
        _ToggleOption(
          label: AppStrings.income,
          icon: Icons.arrow_downward_rounded,
          color: AppColors.income,
          selected: selected == TransactionType.income,
          onTap: () => onChanged(TransactionType.income),
        ),
      ],
    );
  }
}

class _ToggleOption extends StatelessWidget {
  const _ToggleOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? color
                  : scheme.outline.withValues(alpha: 0.3),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected
                    ? color
                    : scheme.onSurface.withValues(alpha: 0.4),
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? color
                      : scheme.onSurface.withValues(alpha: 0.5),
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
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

class _ReceiptViewerPage extends StatelessWidget {
  const _ReceiptViewerPage({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Receipt'),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image_outlined,
                    color: Colors.white54, size: 64),
                SizedBox(height: 12),
                Text(
                  'Image not available',
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
