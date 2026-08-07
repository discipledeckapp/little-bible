import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// On-device store for OTA-downloaded content (US-12).
///
/// Downloaded packages live outside the app bundle and take precedence over the
/// bundled copy, so a story can be corrected without an app store release.
/// Writes are staged to a `.part` file and committed with a rename, which is
/// atomic on both platforms' filesystems — a reader never sees a half-written
/// package, and a process killed mid-download leaves only a stale `.part`.
class ContentStore {
  ContentStore({Directory? root}) : _rootOverride = root;

  final Directory? _rootOverride;
  Directory? _resolved;

  static const partSuffix = '.part';

  Future<Directory> _root() async {
    if (_rootOverride != null) return _rootOverride;
    return _resolved ??= await getApplicationSupportDirectory();
  }

  Future<Directory> _collectionDir(String collection) async {
    final dir = Directory('${(await _root()).path}/content/$collection');
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  Future<File> _fileFor(String collection, String id) async {
    // Ids are namespaced (audio uses `story/scene_0`), so nested dirs are real.
    final file = File('${(await _collectionDir(collection)).path}/$id.json');
    final parent = file.parent;
    if (!parent.existsSync()) await parent.create(recursive: true);
    return file;
  }

  /// Returns the downloaded payload, or null when nothing has been downloaded.
  Future<String?> read(String collection, String id) async {
    final file = await _fileFor(collection, id);
    if (!file.existsSync()) return null;
    return file.readAsString();
  }

  Future<bool> has(String collection, String id) async =>
      (await _fileFor(collection, id)).existsSync();

  /// Stages [bytes] and commits atomically. Returns the committed file.
  ///
  /// [validate] runs against the staged bytes before the commit — if it throws,
  /// the staged file is removed and the previously committed copy is untouched.
  Future<File> commit(
    String collection,
    String id,
    List<int> bytes, {
    void Function(String contents)? validate,
  }) async {
    final target = await _fileFor(collection, id);
    final staged = File('${target.path}$partSuffix');
    try {
      await staged.writeAsBytes(bytes, flush: true);
      if (validate != null) validate(await staged.readAsString());
      return await staged.rename(target.path);
    } catch (_) {
      if (staged.existsSync()) {
        try {
          await staged.delete();
        } catch (_) {
          // Best effort — a leftover .part is swept by sweepPartials().
        }
      }
      rethrow;
    }
  }

  Future<void> remove(String collection, String id) async {
    final file = await _fileFor(collection, id);
    if (file.existsSync()) await file.delete();
  }

  /// Deletes staged files abandoned by a killed process. Returns the count.
  Future<int> sweepPartials() async {
    final root = Directory('${(await _root()).path}/content');
    if (!root.existsSync()) return 0;
    var swept = 0;
    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is File && entity.path.endsWith(partSuffix)) {
        try {
          await entity.delete();
          swept++;
        } catch (_) {
          // Ignore — it will be overwritten by the next download attempt.
        }
      }
    }
    return swept;
  }
}
