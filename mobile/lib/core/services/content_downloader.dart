import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/activity_model.dart';
import '../models/story_model.dart';
import 'content_manifest.dart';
import 'content_store.dart';

/// Fetches the bytes at [url]. Injected so the download path is testable without
/// a network or a platform channel.
typedef ContentFetcher = Future<List<int>> Function(String url);

/// Records that [id] in [collection] is now at [version].
typedef VersionRecorder = Future<void> Function(String key, String version);

class ContentDownloadResult {
  const ContentDownloadResult({
    required this.succeeded,
    required this.failed,
  });

  final List<ManifestEntry> succeeded;
  final List<ManifestEntry> failed;

  bool get allSucceeded => failed.isEmpty;
}

/// Downloads content packages and commits them transactionally (US-12).
///
/// The ordering is what makes a partial download self-healing: bytes are staged,
/// parsed, committed by atomic rename, and only then is the local version
/// recorded. Any failure before the last step leaves the stored version at its
/// previous value, so the next manifest check sees the package as still outdated
/// and simply downloads it again.
class ContentDownloader {
  ContentDownloader({
    required ContentStore store,
    required ContentFetcher fetch,
    required VersionRecorder recordVersion,
  })  : _store = store,
        _fetch = fetch,
        _recordVersion = recordVersion;

  final ContentStore _store;
  final ContentFetcher _fetch;
  final VersionRecorder _recordVersion;

  /// Parses the payload for [collection], throwing if it is not usable. Running
  /// this against the staged bytes is what stops a truncated or HTML error-page
  /// response from ever replacing a good package.
  static void validate(String collection, String contents) {
    final decoded = jsonDecode(contents);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('content payload is not a JSON object');
    }
    switch (collection) {
      case 'stories':
        StoryModel.fromJson(decoded);
      case 'activities':
        ActivityModel.fromJson(decoded);
      default:
        break; // Unknown collections are stored verbatim.
    }
  }

  Future<void> downloadOne(String collection, ManifestEntry entry) async {
    final bytes = await _fetch(entry.url);
    if (bytes.isEmpty) {
      throw const FormatException('empty content response');
    }
    await _store.commit(
      collection,
      entry.id,
      bytes,
      validate: (contents) => validate(collection, contents),
    );
    // Last, and only on success — this is the rollback boundary.
    await _recordVersion(ManifestEntry.versionKey(collection, entry.id), entry.version);
  }

  /// Downloads every entry in [diff]. One failure does not abandon the rest.
  Future<ContentDownloadResult> download(
    String collection,
    ManifestDiff diff, {
    bool Function()? shouldContinue,
  }) async {
    final succeeded = <ManifestEntry>[];
    final failed = <ManifestEntry>[];

    for (final entry in diff.outdated) {
      if (shouldContinue != null && !shouldContinue()) {
        // Paused (e.g. a story session started). Remaining entries stay
        // outdated and are picked up by the next manifest check.
        failed.addAll(diff.outdated.sublist(diff.outdated.indexOf(entry)));
        break;
      }
      try {
        await downloadOne(collection, entry);
        succeeded.add(entry);
      } catch (e) {
        debugPrint('ContentDownloader: $collection/${entry.id} failed — $e');
        failed.add(entry);
      }
    }

    return ContentDownloadResult(succeeded: succeeded, failed: failed);
  }
}
