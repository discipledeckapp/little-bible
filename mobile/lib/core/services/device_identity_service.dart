import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'device_identity_service.g.dart';

const _kDeviceTokenKey = 'com.littlebible.device_token';

@Riverpod(keepAlive: true)
DeviceIdentityService deviceIdentityService(Ref ref) =>
    DeviceIdentityService();

class DeviceIdentityService {
  DeviceIdentityService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  String? _cached;

  /// Returns the persistent device token, generating one on first call.
  ///
  /// The token is a UUID v4 stored in encrypted secure storage. It survives
  /// app updates and serves as the `Authorization: Bearer` credential for
  /// progress sync, replacing a user session cookie.
  Future<String> getOrCreate() async {
    if (_cached != null) return _cached!;
    try {
      final existing = await _storage.read(key: _kDeviceTokenKey);
      if (existing != null && existing.isNotEmpty) {
        _cached = existing;
        return _cached!;
      }
      final fresh = const Uuid().v4();
      await _storage.write(key: _kDeviceTokenKey, value: fresh);
      _cached = fresh;
      return _cached!;
    } catch (_) {
      // Secure storage unavailable (e.g., widget tests without platform setup).
      // Return a transient token so sync is attempted without crashing.
      _cached ??= const Uuid().v4();
      return _cached!;
    }
  }
}
