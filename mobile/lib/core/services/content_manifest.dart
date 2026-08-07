/// Parsing and diffing for the mobile content manifest (US-12).
///
/// The manifest is the only mutable pointer in the content system. Every entry it
/// names is version-addressed and immutable, so a version that differs from the
/// stored one — in either direction — means "download this". Comparison is
/// deliberately by inequality, never by ordering: versions are content hashes and
/// carry no sort order, and a rollback legitimately moves a version "backwards".
library;

class ManifestEntry {
  const ManifestEntry({
    required this.id,
    required this.version,
    required this.url,
    this.bytes = 0,
  });

  final String id;
  final String version;
  final String url;
  final int bytes;

  static ManifestEntry? tryParse(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;
    final id = raw['id'];
    final version = raw['version'];
    final url = raw['url'];
    if (id is! String || id.isEmpty) return null;
    if (version is! String || version.isEmpty) return null;
    if (url is! String || url.isEmpty) return null;
    return ManifestEntry(
      id: id,
      version: version,
      url: url,
      bytes: (raw['bytes'] as num?)?.toInt() ?? 0,
    );
  }

  /// Key used in the local ContentVersions table. Namespaced by collection so a
  /// story and its activity never collide on a shared id.
  static String versionKey(String collection, String id) => '$collection:$id';

  @override
  String toString() => 'ManifestEntry($id@$version)';
}

class ContentManifest {
  const ContentManifest({required this.collections});

  /// Collection name ('stories' | 'activities' | 'audio') → entries.
  final Map<String, List<ManifestEntry>> collections;

  static const empty = ContentManifest(collections: {});

  List<ManifestEntry> operator [](String collection) => collections[collection] ?? const [];

  /// Tolerant parser — a malformed entry is skipped rather than failing the whole
  /// manifest, so one bad package can never block every other update.
  static ContentManifest parse(Object? raw) {
    if (raw is! Map<String, dynamic>) return empty;
    final content = raw['content'];
    if (content is! Map<String, dynamic>) return empty;

    final collections = <String, List<ManifestEntry>>{};
    for (final entry in content.entries) {
      final value = entry.value;
      if (value is! Map<String, dynamic>) continue;
      final items = value['items'];
      if (items is! List) continue;
      final parsed = items
          .map(ManifestEntry.tryParse)
          .whereType<ManifestEntry>()
          .toList(growable: false);
      if (parsed.isNotEmpty) collections[entry.key] = parsed;
    }
    return ContentManifest(collections: collections);
  }
}

/// The set of entries whose local copy is missing or out of date.
class ManifestDiff {
  const ManifestDiff({required this.outdated});

  final List<ManifestEntry> outdated;

  bool get isEmpty => outdated.isEmpty;
  int get length => outdated.length;

  /// [localVersions] maps entry id → the version currently stored locally.
  /// A null value means the content has never been downloaded.
  static ManifestDiff compute({
    required List<ManifestEntry> remote,
    required Map<String, String?> localVersions,
  }) {
    final outdated = <ManifestEntry>[];
    for (final entry in remote) {
      final local = localVersions[entry.id];
      if (local == null || local != entry.version) {
        outdated.add(entry);
      }
    }
    return ManifestDiff(outdated: outdated);
  }
}
