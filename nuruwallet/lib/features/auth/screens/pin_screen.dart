import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';

enum PinMode { verify, setup, confirm }

class PinScreen extends ConsumerStatefulWidget {
  const PinScreen({super.key, required this.mode, this.setupPin});

  final PinMode mode;
  final String? setupPin;

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> {
  static const _maxLen = 4;

  String _pin = '';
  String? _error;
  bool _busy = false;

  void _key(String digit) {
    if (_pin.length >= _maxLen || _busy) return;
    setState(() {
      _pin += digit;
      _error = null;
    });
    if (_pin.length == _maxLen) _onComplete();
  }

  void _del() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _onComplete() async {
    switch (widget.mode) {
      case PinMode.verify:
        setState(() => _busy = true);
        final ok = await ref.read(authProvider.notifier).verifyPin(_pin);
        if (!ok && mounted) {
          setState(() {
            _pin = '';
            _error = 'Incorrect PIN. Try again.';
            _busy = false;
          });
        }

      case PinMode.setup:
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PinScreen(mode: PinMode.confirm, setupPin: _pin),
          ),
        );

      case PinMode.confirm:
        if (_pin == widget.setupPin) {
          setState(() => _busy = true);
          await ref.read(authProvider.notifier).setPin(_pin);
          if (mounted) Navigator.pop(context);
        } else {
          setState(() {
            _pin = '';
            _error = 'PINs do not match. Try again.';
          });
        }
    }
  }

  Future<void> _biometric() async {
    await ref.read(authProvider.notifier).authenticateWithBiometric();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final scheme = Theme.of(context).colorScheme;

    final (title, subtitle) = switch (widget.mode) {
      PinMode.verify => ('Welcome back', 'Enter your PIN to continue'),
      PinMode.setup => ('Create PIN', 'Choose a 4-digit PIN for your wallet'),
      PinMode.confirm => ('Confirm PIN', 'Enter the PIN again to confirm'),
    };

    final showBiometric = widget.mode == PinMode.verify &&
        auth.isBiometricEnabled &&
        auth.isBiometricAvailable;

    return Scaffold(
      appBar: widget.mode != PinMode.verify
          ? AppBar(
              title: Text(title),
              backgroundColor: Colors.transparent,
              elevation: 0,
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App logo
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF14B8A6), Color(0xFF0F766E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Center(
                      child: Text(
                        'N',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (widget.mode == PinMode.verify)
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: scheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),

                  // PIN dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_maxLen, (i) {
                      final filled = i < _pin.length;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: filled ? AppColors.primary : Colors.transparent,
                          border: Border.all(
                            color: filled
                                ? AppColors.primary
                                : scheme.onSurface.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                      );
                    }),
                  ),

                  // Error / busy
                  SizedBox(
                    height: 32,
                    child: _busy
                        ? const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2),
                            ),
                          )
                        : _error != null
                            ? Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.expense,
                                  ),
                                ),
                              )
                            : null,
                  ),
                ],
              ),
            ),

            // Keypad
            Padding(
              padding: const EdgeInsets.fromLTRB(48, 0, 48, 40),
              child: Column(
                children: [
                  for (final row in [
                    ['1', '2', '3'],
                    ['4', '5', '6'],
                    ['7', '8', '9'],
                  ]) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: row
                          .map((d) => _KeyBtn(
                              label: d, onTap: _busy ? null : () => _key(d)))
                          .toList(),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      showBiometric
                          ? _IconBtn(
                              icon: Icons.fingerprint,
                              onTap: _busy ? null : _biometric,
                            )
                          : const SizedBox(width: 72, height: 72),
                      _KeyBtn(label: '0', onTap: _busy ? null : () => _key('0')),
                      _IconBtn(
                        icon: Icons.backspace_outlined,
                        onTap: _busy ? null : _del,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KeyBtn extends StatelessWidget {
  const _KeyBtn({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(36),
      child: SizedBox(
        width: 72,
        height: 72,
        child: Center(
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w400),
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(36),
      child: SizedBox(
        width: 72,
        height: 72,
        child: Center(child: Icon(icon, size: 28)),
      ),
    );
  }
}
