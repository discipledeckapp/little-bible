import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/app_database.dart';
import '../providers/database_provider.dart';
import 'content_downloader.dart';
import 'content_manifest.dart';
import 'content_session.dart';
import 'content_store.dart';
import '../providers/profile_provider.dart';

part 'content_update_service.g.dart';

const _kManifestUrl = 'https://littlebible.org/api/mobile/manifest';

/// Collections the app downloads. Audio is published to R2 but stays bundled for
/// now — pulling ~19MB of MP3s belongs behind the Wi-Fi-only download setting.
const _kDownloadedCollections = ['stories', 'activities'];

@Riverpod(keepAlive: true)
ContentStore contentStore(Ref ref) => ContentStore();

@riverpod
ContentUpdateService contentUpdateService(Ref ref) {
  return ContentUpdateService(
    db: ref.watch(databaseProvider),
    store: ref.watch(contentStoreProvider),
    isSessionActive: () => ref.read(storySessionActiveProvider),
    onContentChanged: () => ref.read(contentRevisionProvider.notifier).bump(),
    isWifiOnly: () =>
        ref.read(activeProfileProvider).valueOrNull?.wifiOnlyDownloads ?? false,
  );
}

class ContentUpdateService {
  ContentUpdateService({
    required AppDatabase db,
    required ContentStore store,
    required bool Function() isSessionActive,
    required VoidCallback onContentChanged,
    bool Function()? isWifiOnly,
    Dio? dio,
    String manifestUrl = _kManifestUrl,
  })  : _db = db,
        _store = store,
        _isSessionActive = isSessionActive,
        _onContentChanged = onContentChanged,
        _isWifiOnly = isWifiOnly,
        _manifestUrl = manifestUrl,
        _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 30),
            ));

  final AppDatabase _db;
  final ContentStore _store;
  final bool Function() _isSessionActive;
  final VoidCallback _onContentChanged;
  final bool Function()? _isWifiOnly;
  final String _manifestUrl;
  final Dio _dio;

  bool _running = false;

  /// Call on app foreground. Never blocks a read and never throws — content
  /// delivery is an optimisation, and the bundled catalogue is always usable.
  Future<void> checkManifest() async {
    if (_running) return; // A check is already in flight.

    // Respect the parent's Wi-Fi-only download preference.
    // Wrapped in try/catch: the platform channel may be absent in tests or
    // unsupported environments — a failed check must never block downloads.
    if (_isWifiOnly != null && _isWifiOnly()) {
      try {
        final result = await Connectivity().checkConnectivity();
        if (!result.contains(ConnectivityResult.wifi)) {
          debugPrint('ContentUpdateService: deferring — Wi-Fi only, not on Wi-Fi');
          return;
        }
      } catch (_) {
        // Connectivity detection unavailable — proceed with download attempt.
      }
    }

    _running = true;
    try {
      // Clear anything a previous run was killed part-way through, so a stale
      // staged file can never be mistaken for a committed package.
      await _store.sweepPartials();

      final manifest = await _fetchManifest();
      if (manifest == null) return;

      final localVersions = await _db.getAllContentVersions();
      var changed = false;

      for (final collection in _kDownloadedCollections) {
        final remote = manifest[collection];
        if (remote.isEmpty) continue;

        final diff = ManifestDiff.compute(
          remote: remote,
          localVersions: {
            for (final entry in remote)
              entry.id: localVersions[ManifestEntry.versionKey(collection, entry.id)],
          },
        );
        if (diff.isEmpty) continue;

        if (_isSessionActive()) {
          // Queue behind the active session — retried on the next foreground.
          debugPrint(
            'ContentUpdateService: deferring ${diff.length} $collection '
            'update(s) — story session in progress',
          );
          return;
        }

        debugPrint('ContentUpdateService: ${diff.length} $collection update(s)');
        final result = await _downloader().download(
          collection,
          diff,
          shouldContinue: () => !_isSessionActive(),
        );
        if (result.succeeded.isNotEmpty) changed = true;
      }

      if (changed) _onContentChanged();
    } catch (e) {
      debugPrint('ContentUpdateService: manifest check failed — $e');
    } finally {
      _running = false;
    }
  }

  ContentDownloader _downloader() => ContentDownloader(
        store: _store,
        fetch: _fetchBytes,
        recordVersion: _db.upsertContentVersion,
      );

  Future<List<int>> _fetchBytes(String url) async {
    final res = await _dio.get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    if (res.statusCode != 200 || res.data == null) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: 'content fetch returned ${res.statusCode}',
      );
    }
    return res.data!;
  }

  Future<ContentManifest?> _fetchManifest() async {
    final res = await _dio.get<String>(_manifestUrl);
    if (res.statusCode != 200 || res.data == null) return null;
    return ContentManifest.parse(jsonDecode(res.data!));
  }
}
