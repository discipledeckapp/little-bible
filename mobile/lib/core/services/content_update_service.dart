import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/app_database.dart';
import '../providers/database_provider.dart';

part 'content_update_service.g.dart';

const _kManifestUrl = 'https://littlebible.org/api/mobile/manifest';

@riverpod
ContentUpdateService contentUpdateService(Ref ref) {
  final db = ref.watch(databaseProvider);
  return ContentUpdateService(db);
}

class ContentUpdateService {
  ContentUpdateService(this._db);
  final AppDatabase _db;

  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
  ));

  /// Call on app foreground (non-blocking — catches all errors).
  Future<void> checkManifest() async {
    try {
      final res = await _dio.get<String>(_kManifestUrl);
      if (res.statusCode != 200 || res.data == null) return;

      final body = jsonDecode(res.data!) as Map<String, dynamic>;
      final items = ((body['content'] as Map<String, dynamic>?)?['stories']
              as Map<String, dynamic>?)?['items'] as List<dynamic>? ??
          [];

      for (final raw in items) {
        final entry = raw as Map<String, dynamic>;
        final storyId = entry['id'] as String;
        final version = (entry['version'] as String?) ?? '';
        final local = await _db.getContentVersion(storyId);
        if (local == null || local.compareTo(version) < 0) {
          debugPrint('ContentUpdateService: new version for $storyId ($version)');
          await _db.upsertContentVersion(storyId, version);
        }
      }
    } catch (e) {
      debugPrint('ContentUpdateService: manifest check failed — $e');
    }
  }
}
