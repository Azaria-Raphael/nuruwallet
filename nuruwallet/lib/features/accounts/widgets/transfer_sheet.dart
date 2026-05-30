import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/account_icon.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/database/app_database.dart';
import '../../../data/providers/repository_providers.dart';

void showTransferSheet(BuildContext context, {AccountEntry? fromAccount}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => TransferSheet(fromAccount: fromAccount),
  );
}

class TransferSheet extends ConsumerStatefulWidget {
  const TransferSheet({super.key, this.fromAccount});

  final AccountEntry? fromAccount;

  @override
  ConsumerState<TransferSheet> createState() => _TransferSheetState();
}

class _TransferSheetState extends ConsumerState<TransferSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String? _fromId;
  String? _toId;
  bool _saving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_fromId == null || _toId == null) {
      _toast('Select both accounts.');
      return;
    }
    if (_fromId == _toId) {
      _toast('From and To accounts must be different.');
      return;
    }

    setState(() => _saving = true);
    try {
      final amount =
          double.parse(_amountController.text.replaceAll(',', ''));
      final repo = ref.read(accountRepositoryProvider);
      await repo.adjustBalance(_fromId!, -amount);
      await repo.adjustBalance(_toId!, amount);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) _toast('Transfer failed: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(msg), behavior: SnackBarBehavior.floating),
      );

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(allAccountsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    accountsAsync.whenData((accounts) {
      if (!_initialized && accounts.isNotEmpty) {
        _initialized = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _fromId = widget.fromAccount?.id ?? accounts.first.id;
            _toId = accounts.length > 1
                ? accounts.firstWhere((a) => a.id != _fromId).id
                : null;
          });
        });
      }
    });

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
                  AppStrings.transferBetweenAccounts,
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
                child: accountsAsync.when(
                  data: (accounts) {
                    if (accounts.length < 2) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'You need at least 2 accounts to transfer.',
                            style: TextStyle(
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    final toOptions = accounts
                        .where((a) => a.id != _fromId)
                        .toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // From
                        DropdownButtonFormField<String>(
                          initialValue: _fromId,
                          decoration: const InputDecoration(
                            labelText: 'From',
                            prefixIcon: Icon(Icons.arrow_upward,
                                size: 18),
                          ),
                          items: accounts
                              .map((a) => DropdownMenuItem(
                                    value: a.id,
                                    child: _AccountDropdownItem(a),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() {
                            _fromId = v;
                            if (_toId == v) _toId = null;
                          }),
                        ),
                        const SizedBox(height: 12),

                        // To
                        DropdownButtonFormField<String>(
                          initialValue:
                              toOptions.any((a) => a.id == _toId)
                                  ? _toId
                                  : null,
                          decoration: const InputDecoration(
                            labelText: 'To',
                            prefixIcon: Icon(Icons.arrow_downward,
                                size: 18),
                          ),
                          items: toOptions
                              .map((a) => DropdownMenuItem(
                                    value: a.id,
                                    child: _AccountDropdownItem(a),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _toId = v),
                          validator: (v) =>
                              v == null ? 'Select destination.' : null,
                        ),
                        const SizedBox(height: 20),

                        // Amount
                        TextFormField(
                          controller: _amountController,
                          autofocus: true,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[\d.,]')),
                          ],
                          decoration: const InputDecoration(
                            labelText: AppStrings.amount,
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
                            // Check sufficient balance
                            if (_fromId != null) {
                              final from = accounts.firstWhere(
                                  (a) => a.id == _fromId);
                              if (n > from.balance) {
                                return 'Insufficient balance (${CurrencyFormatter.format(from.balance)}).';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Note
                        TextFormField(
                          controller: _noteController,
                          decoration: InputDecoration(
                            labelText: AppStrings.note,
                            prefixIcon:
                                const Icon(Icons.notes_outlined),
                          ),
                          textCapitalization:
                              TextCapitalization.sentences,
                        ),
                        const SizedBox(height: 28),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _saving ? null : _save,
                            child: _saving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white),
                                  )
                                : const Text(
                                    'Transfer',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('$e'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountDropdownItem extends StatelessWidget {
  const _AccountDropdownItem(this.account);
  final AccountEntry account;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor:
              Color(account.colorValue).withValues(alpha: 0.15),
          child: Icon(
            AccountIcon.get(account.type),
            size: 13,
            color: Color(account.colorValue),
          ),
        ),
        const SizedBox(width: 8),
        Text(account.name),
      ],
    );
  }
}
