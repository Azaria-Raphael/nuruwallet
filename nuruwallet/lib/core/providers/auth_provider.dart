import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthState {
  const AuthState({
    this.isPinSet = false,
    this.sessionUnlocked = false,
    this.isBiometricEnabled = false,
    this.isBiometricAvailable = false,
  });

  final bool isPinSet;
  final bool sessionUnlocked;
  final bool isBiometricEnabled;
  final bool isBiometricAvailable;

  AuthState copyWith({
    bool? isPinSet,
    bool? sessionUnlocked,
    bool? isBiometricEnabled,
    bool? isBiometricAvailable,
  }) =>
      AuthState(
        isPinSet: isPinSet ?? this.isPinSet,
        sessionUnlocked: sessionUnlocked ?? this.sessionUnlocked,
        isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
        isBiometricAvailable:
            isBiometricAvailable ?? this.isBiometricAvailable,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _keyPin = 'nuru_pin_hash';
  static const _keyBiometric = 'biometric_enabled';
  static final _localAuth = LocalAuthentication();

  static String _hash(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  Future<void> load() async {
    String? pinHash;
    try {
      pinHash = await _storage.read(key: _keyPin);
    } catch (_) {}

    final isPinSet = pinHash != null && pinHash.isNotEmpty;

    final prefs = await SharedPreferences.getInstance();
    final isBiometricEnabled = prefs.getBool(_keyBiometric) ?? false;

    bool isBiometricAvailable = false;
    try {
      isBiometricAvailable = await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
    } catch (_) {}

    state = AuthState(
      isPinSet: isPinSet,
      sessionUnlocked: !isPinSet,
      isBiometricEnabled: isBiometricEnabled,
      isBiometricAvailable: isBiometricAvailable,
    );
  }

  Future<bool> verifyPin(String pin) async {
    String? stored;
    try {
      stored = await _storage.read(key: _keyPin);
    } catch (_) {}
    if (stored == null) return false;
    final match = stored == _hash(pin);
    if (match) state = state.copyWith(sessionUnlocked: true);
    return match;
  }

  Future<void> setPin(String pin) async {
    await _storage.write(key: _keyPin, value: _hash(pin));
    state = state.copyWith(isPinSet: true, sessionUnlocked: true);
  }

  Future<void> removePin() async {
    await _storage.delete(key: _keyPin);
    await _setBiometricPref(false);
    state = state.copyWith(
      isPinSet: false,
      sessionUnlocked: true,
      isBiometricEnabled: false,
    );
  }

  Future<bool> authenticateWithBiometric() async {
    try {
      final ok = await _localAuth.authenticate(
        localizedReason: 'Unlock NuruWallet',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (ok) state = state.copyWith(sessionUnlocked: true);
      return ok;
    } catch (_) {
      return false;
    }
  }

  Future<void> toggleBiometric() async {
    if (!state.isBiometricEnabled) {
      final ok = await authenticateWithBiometric();
      if (!ok) return;
      await _setBiometricPref(true);
      state = state.copyWith(isBiometricEnabled: true);
    } else {
      await _setBiometricPref(false);
      state = state.copyWith(isBiometricEnabled: false);
    }
  }

  void lock() {
    if (state.isPinSet) {
      state = state.copyWith(sessionUnlocked: false);
    }
  }

  Future<void> _setBiometricPref(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBiometric, value);
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());
