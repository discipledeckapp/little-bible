import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../theme/app_theme.dart';

part 'parent_gate_service.g.dart';

const _kPinKey = 'parent_hub_pin';

@riverpod
ParentGateService parentGateService(Ref ref) {
  final service = ParentGateService();
  ref.onDispose(service.dispose);
  return service;
}

class ParentGateService with WidgetsBindingObserver {
  ParentGateService() {
    WidgetsBinding.instance.addObserver(this);
  }

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final _localAuth = LocalAuthentication();

  DateTime? _authenticatedUntil;
  int _failedAttempts = 0;
  DateTime? _lockedUntil;

  bool get isAuthenticated =>
      _authenticatedUntil?.isAfter(DateTime.now()) ?? false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) expire();
  }

  void expire() => _authenticatedUntil = null;

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  Future<bool> hasPin() async {
    final pin = await _storage.read(key: _kPinKey);
    return pin != null && pin.isNotEmpty;
  }

  Future<void> setPin(String pin) =>
      _storage.write(key: _kPinKey, value: pin);

  Future<bool> verifyPin(String pin) async {
    final lockedUntil = _lockedUntil;
    if (lockedUntil != null && lockedUntil.isAfter(DateTime.now())) return false;
    final stored = await _storage.read(key: _kPinKey);
    final valid = stored == pin;
    if (valid) {
      _failedAttempts = 0;
      _lockedUntil = null;
      return true;
    }
    _failedAttempts++;
    if (_failedAttempts >= 5) {
      _failedAttempts = 0;
      _lockedUntil = DateTime.now().add(const Duration(minutes: 1));
    }
    return false;
  }

  /// Returns true if the device has any enrolled biometric or device credential.
  Future<bool> get canUseBiometrics async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      if (!supported) return false;
      final available = await _localAuth.canCheckBiometrics;
      return available;
    } on PlatformException {
      return false;
    }
  }

  /// Human-readable label for the available auth method.
  Future<String> get biometricLabel async {
    try {
      final types = await _localAuth.getAvailableBiometrics();
      if (types.contains(BiometricType.face)) return 'Face ID';
      if (types.contains(BiometricType.fingerprint)) return 'fingerprint';
      if (types.contains(BiometricType.strong)) return 'biometrics';
      if (types.contains(BiometricType.weak)) return 'biometrics';
      return 'device PIN';
    } on PlatformException {
      return 'biometrics';
    }
  }

  /// Prompts biometric / device-credential authentication. Returns true on success.
  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Confirm it\'s you to access the Parent Hub',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }

  /// Shows the PIN gate modal. Returns true if the parent is authenticated.
  /// Handles first-time setup (PIN creation) automatically.
  Future<bool> showGate(BuildContext context) async {
    if (!context.mounted) return false;
    if (isAuthenticated) return true;

    final isPinSet = await hasPin();
    final bioAvailable = await canUseBiometrics;
    final bioLabel = bioAvailable ? await biometricLabel : 'biometrics';

    if (!context.mounted) return false;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ParentGateSheet(
        isSetup: !isPinSet,
        bioAvailable: bioAvailable && isPinSet,
        bioLabel: bioLabel,
        onVerify: (pin) async {
          if (!isPinSet) {
            await setPin(pin);
            return true;
          }
          return verifyPin(pin);
        },
        onBioAuth: (bioAvailable && isPinSet)
            ? () => authenticateWithBiometrics()
            : null,
        onBioReset: (bioAvailable && isPinSet)
            ? () async {
                final ok = await authenticateWithBiometrics();
                if (ok) await setPin('');
                return ok;
              }
            : null,
      ),
    );

    final accepted = result ?? false;
    if (accepted) {
      _authenticatedUntil = DateTime.now().add(const Duration(minutes: 5));
    }
    return accepted;
  }
}

// ─── PIN gate bottom sheet ────────────────────────────────────────────────────

class _ParentGateSheet extends StatefulWidget {
  const _ParentGateSheet({
    required this.isSetup,
    required this.bioAvailable,
    required this.bioLabel,
    required this.onVerify,
    this.onBioAuth,
    this.onBioReset,
  });

  final bool isSetup;
  final bool bioAvailable;
  final String bioLabel;
  final Future<bool> Function(String pin) onVerify;

  /// Authenticate with biometrics as the primary method (not just reset).
  final Future<bool> Function()? onBioAuth;
  final Future<bool> Function()? onBioReset;

  @override
  State<_ParentGateSheet> createState() => _ParentGateSheetState();
}

class _ParentGateSheetState extends State<_ParentGateSheet> {
  final List<int> _digits = [];
  bool _wrong = false;
  bool _confirming = false;
  List<int> _firstPin = [];
  bool _bioLoading = false;
  // Start on biometric view when available and not in setup mode.
  late bool _showPin;

  @override
  void initState() {
    super.initState();
    _showPin = widget.isSetup || !widget.bioAvailable;
    if (!_showPin) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryBioAuth());
    }
  }

  void _onDigit(int d) {
    if (_digits.length >= 4) return;
    setState(() { _digits.add(d); _wrong = false; });
    if (_digits.length == 4) _submit();
  }

  void _onDelete() {
    if (_digits.isEmpty) return;
    setState(() => _digits.removeLast());
  }

  Future<void> _submit() async {
    final pin = _digits.join();

    if (widget.isSetup && !_confirming) {
      setState(() {
        _confirming = true;
        _firstPin = List.from(_digits);
        _digits.clear();
      });
      return;
    }

    if (widget.isSetup && _confirming) {
      if (pin == _firstPin.join()) {
        final ok = await widget.onVerify(pin);
        if (mounted) Navigator.of(context).pop(ok);
      } else {
        setState(() {
          _digits.clear();
          _firstPin.clear();
          _confirming = false;
          _wrong = true;
        });
      }
      return;
    }

    final ok = await widget.onVerify(pin);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() { _digits.clear(); _wrong = true; });
    }
  }

  Future<void> _tryBioAuth() async {
    if (widget.onBioAuth == null || !mounted) return;
    setState(() => _bioLoading = true);
    final ok = await widget.onBioAuth!();
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() { _bioLoading = false; _showPin = true; });
    }
  }

  Future<void> _forgotPin() async {
    if (widget.onBioReset == null) return;
    setState(() => _bioLoading = true);
    final ok = await widget.onBioReset!();
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN cleared — please set a new PIN.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      setState(() { _bioLoading = false; _wrong = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isSetup
        ? (_confirming ? 'Confirm your PIN' : 'Create a parent PIN')
        : 'Parent Hub';
    final subtitle = widget.isSetup
        ? (_confirming
            ? 'Enter the same 4 digits again'
            : 'Choose a 4-digit PIN to protect Parent Hub')
        : (_showPin ? 'Enter your 4-digit PIN' : 'Verify it\'s you');

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: AppColours.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColours.textMuted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Icon(Icons.shield_rounded, color: AppColours.lumiGold, size: 36),
              const SizedBox(height: 12),
              Text(title,
                  style: AppTextStyles.heading.copyWith(
                      color: AppColours.textDark, fontSize: 20)),
              const SizedBox(height: 6),
              Text(subtitle,
                  style: AppTextStyles.label.copyWith(
                      color: AppColours.textMuted, fontSize: 13)),
              const SizedBox(height: 28),

              // ── Biometric-first view ─────────────────────────────────────
              if (!widget.isSetup && widget.bioAvailable && !_showPin) ...[
                _bioLoading
                    ? Column(
                        children: [
                          const SizedBox(
                            width: 56, height: 56,
                            child: CircularProgressIndicator(
                                strokeWidth: 3, color: AppColours.lumiGold),
                          ),
                          const SizedBox(height: 14),
                          Text('Waiting for ${widget.bioLabel}…',
                              style: AppTextStyles.label.copyWith(
                                  color: AppColours.textMuted, fontSize: 13)),
                        ],
                      )
                    : GestureDetector(
                        onTap: _tryBioAuth,
                        child: Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            color: AppColours.lumiGold.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColours.lumiGold.withValues(alpha: 0.3),
                                width: 2),
                          ),
                          child: const Icon(Icons.fingerprint_rounded,
                              color: AppColours.lumiGold, size: 44),
                        ),
                      ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => setState(() { _showPin = true; }),
                  style: TextButton.styleFrom(foregroundColor: AppColours.textMuted),
                  child: Text('Use PIN instead',
                      style: AppTextStyles.label.copyWith(
                          fontSize: 13, color: AppColours.textMuted,
                          decoration: TextDecoration.underline)),
                ),
                const SizedBox(height: 8),
              ],

              // ── PIN keypad view ──────────────────────────────────────────
              if (widget.isSetup || _showPin) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    4,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 18, height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < _digits.length
                            ? (_wrong ? AppColours.coral : AppColours.lumiGold)
                            : AppColours.lumiGold.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),
                if (_wrong) ...[
                  const SizedBox(height: 10),
                  Text(
                    widget.isSetup
                        ? 'PINs don\'t match — try again'
                        : 'Incorrect PIN — try again',
                    style: AppTextStyles.label.copyWith(
                        color: AppColours.coral, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 32),
                _Keypad(onDigit: _onDigit, onDelete: _onDelete),
                const SizedBox(height: 16),

                // Switch to biometric / forgot PIN row
                if (!widget.isSetup && widget.bioAvailable)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: _bioLoading
                            ? null
                            : () => setState(() {
                                  _showPin = false;
                                  _digits.clear();
                                  _wrong = false;
                                }),
                        icon: const Icon(Icons.fingerprint_rounded, size: 16),
                        label: Text('Use ${widget.bioLabel}'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColours.lumiGold,
                          textStyle: AppTextStyles.label.copyWith(fontSize: 13),
                        ),
                      ),
                      Text(' · ',
                          style: AppTextStyles.label
                              .copyWith(color: AppColours.textMuted)),
                      TextButton(
                        onPressed: _bioLoading ? null : _forgotPin,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColours.textMuted,
                          textStyle: AppTextStyles.label.copyWith(fontSize: 13),
                        ),
                        child: const Text('Forgot PIN?'),
                      ),
                    ],
                  )
                else
                  const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onDigit, required this.onDelete});

  final void Function(int) onDigit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    const rows = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9],
    ];
    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final d in row) _Key(label: '$d', onTap: () => onDigit(d)),
              ],
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 76),
            _Key(label: '0', onTap: () => onDigit(0)),
            _Key(icon: Icons.backspace_outlined, onTap: onDelete),
          ],
        ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({this.label, this.icon, required this.onTap});

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72, height: 56,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColours.cream,
          borderRadius: BorderRadius.circular(14),
        ),
        child: icon != null
            ? Icon(icon, color: AppColours.textDark, size: 22)
            : Text(
                label!,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColours.textDark,
                ),
              ),
      ),
    );
  }
}
