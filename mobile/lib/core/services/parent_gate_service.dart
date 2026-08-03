import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  /// Shows the PIN gate modal. Returns true if the parent is authenticated.
  /// Handles first-time setup (PIN creation) automatically.
  Future<bool> showGate(BuildContext context) async {
    if (!context.mounted) return false;

    if (isAuthenticated) return true;

    final isPinSet = await hasPin();

    if (!context.mounted) return false;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ParentGateSheet(
        isSetup: !isPinSet,
        onVerify: (pin) async {
          if (!isPinSet) {
            await setPin(pin);
            return true;
          }
          return verifyPin(pin);
        },
      ),
    );

    final accepted = result ?? false;
    if (accepted) {
      _authenticatedUntil = DateTime.now().add(const Duration(minutes: 5));
    }
    return accepted;
  }
}

// ─── PIN entry bottom sheet ───────────────────────────────────────────────────

class _ParentGateSheet extends StatefulWidget {
  const _ParentGateSheet({
    required this.isSetup,
    required this.onVerify,
  });

  final bool isSetup;
  final Future<bool> Function(String pin) onVerify;

  @override
  State<_ParentGateSheet> createState() => _ParentGateSheetState();
}

class _ParentGateSheetState extends State<_ParentGateSheet> {
  final List<int> _digits = [];
  bool _wrong = false;
  bool _confirming = false;
  List<int> _firstPin = [];

  void _onDigit(int d) {
    if (_digits.length >= 4) return;
    setState(() {
      _digits.add(d);
      _wrong = false;
    });
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
      setState(() {
        _digits.clear();
        _wrong = true;
      });
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
        : 'Enter your 4-digit PIN';

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
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
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColours.textMuted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Icon(Icons.shield_rounded,
                  color: AppColours.lumiGold, size: 36),
              const SizedBox(height: 12),
              Text(title,
                  style: AppTextStyles.heading.copyWith(
                      color: AppColours.textDark, fontSize: 20)),
              const SizedBox(height: 6),
              Text(subtitle,
                  style: AppTextStyles.label.copyWith(
                      color: AppColours.textMuted, fontSize: 13)),
              const SizedBox(height: 28),

              // PIN dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < _digits.length
                          ? (_wrong
                              ? AppColours.coral
                              : AppColours.lumiGold)
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
                  style: AppTextStyles.label
                      .copyWith(color: AppColours.coral, fontSize: 12),
                ),
              ],
              const SizedBox(height: 32),

              // Numeric keypad
              _Keypad(onDigit: _onDigit, onDelete: _onDelete),
              const SizedBox(height: 8),
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
            _Key(
              icon: Icons.backspace_outlined,
              onTap: onDelete,
            ),
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
        width: 72,
        height: 56,
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
