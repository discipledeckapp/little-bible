import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/app_database.dart';
import '../providers/database_provider.dart';

part 'sync_service.g.dart';

const _kBackendBase = 'https://littlebible.org';

@riverpod
SyncService syncService(Ref ref) {
  final db = ref.watch(databaseProvider);
  return SyncService(db);
}

class SyncService {
  SyncService(this._db);
  final AppDatabase _db;
  bool _syncing = false;

  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// Call on app foreground + after any story completion.
  /// No-op if already syncing or no pending entries.
  Future<void> drain({String? sessionCookie}) async {
    if (_syncing || sessionCookie == null) return;
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

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Cookie': sessionCookie,
      };

      if (progressEntries.isNotEmpty) {
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
          options: Options(headers: headers),
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
          options: Options(headers: headers),
        );
        if (res.statusCode == 200) {
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
