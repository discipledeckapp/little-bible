import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/app_database.dart';
import '../providers/database_provider.dart';
import 'device_identity_service.dart';

part 'sync_service.g.dart';

const _kBackendBase = 'https://littlebible.org';

@riverpod
SyncService syncService(Ref ref) {
  final db = ref.watch(databaseProvider);
  final deviceIdentity = ref.watch(deviceIdentityServiceProvider);
  return SyncService(db, deviceIdentity);
}

class SyncService {
  SyncService(this._db, this._deviceIdentity);

  final AppDatabase _db;
  final DeviceIdentityService _deviceIdentity;
  bool _syncing = false;

  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// Call on app foreground + after any story completion.
  ///
  /// Progress entries are authenticated with the device's Bearer token
  /// (UUID in secure storage), which the backend stores against a deviceId
  /// column — no user session required. Unlock entries authenticate on the
  /// store-signed receipt itself and are sent without the token.
  Future<void> drain() async {
    if (_syncing) return;
    _syncing = true;
    try {
      final pending = await _db.getPendingSyncEntries();
      if (pending.isEmpty) return;

      final unlockEntries = <SyncQueueData>[];
      final progressEntries = <SyncQueueData>[];
      for (final e in pending) {
        if (e.operation == 'unlock') {
          unlockEntries.add(e);
        } else {
          progressEntries.add(e);
        }
      }

      if (progressEntries.isNotEmpty) {
        final deviceToken = await _deviceIdentity.getOrCreate();
        final entries = progressEntries.map((e) {
          final decoded = jsonDecode(e.payload) as Map<String, dynamic>;
          return <String, dynamic>{
            'clientId': e.id.toString(),
            'profileId': e.profileId,
            'operation': e.operation,
            'payload': decoded,
            'createdAt': e.createdAt.toIso8601String(),
          };
        }).toList();

        final res = await _dio.post(
          '$_kBackendBase/api/mobile/progress',
          data: {'entries': entries},
          options: Options(headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $deviceToken',
          }),
        );
        if (res.statusCode == 200) {
          await _db.markSyncEntriesSynced(progressEntries.map((e) => e.id).toList());
        }
      }

      for (final e in unlockEntries) {
        final decoded = jsonDecode(e.payload) as Map<String, dynamic>;
        final res = await _dio.post(
          '$_kBackendBase/api/mobile/unlock',
          data: decoded,
          options: Options(
            headers: {'Content-Type': 'application/json'},
            // 403 = store rejected receipt; it will never succeed, so clear it.
            validateStatus: (s) => s != null && s < 500,
          ),
        );
        if (res.statusCode == 200 || res.statusCode == 403 || res.statusCode == 400) {
          await _db.markSyncEntriesSynced([e.id]);
        }
      }
    } catch (e) {
      debugPrint('SyncService: drain failed — $e');
    } finally {
      _syncing = false;
    }
  }
}
