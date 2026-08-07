import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:little_bible/core/services/content_downloader.dart';
import 'package:little_bible/core/services/content_manifest.dart';
import 'package:little_bible/core/services/content_store.dart';

// Covers the US-12 unit rows: manifest diffing, and a download that rolls back
// cleanly on partial failure so the next check re-downloads it.

Map<String, dynamic> _manifestJson(List<Map<String, dynamic>> stories) => {
      'schemaVersion': 1,
      'content': {
        'stories': {'version': 'v1', 'items': stories},
      },
    };

Map<String, dynamic> _item(String id, String version) => {
      'id': id,
      'version': version,
      'key': 'stories/$id/$version.json',
      'url': 'https://littlebible.org/api/content/stories/$id/$version.json',
      'bytes': 100,
    };

String _validStory(String id, {String title = 'A Story'}) => jsonEncode({
      'id': id,
      'sensitivityTier': 'general',
      'genre': 'narrative',
      'verseContext': 'A sentence of context that is long enough to be real.',
      'title': title,
      'subtitle': '',
      'collection': 'test',
      'mainTruth': 'God is good.',
      'bibleRef': 'Genesis 1',
      'coverEmoji': '📖',
      'coverColor': '#FFAA00',
      'steps': {
        'read': {'text': 'Parent text', 'childText': 'Child text', 'verses': []},
        'discuss': {'question': 'What happened?', 'parentGuide': ''},
        'pray': {'guidedPrayer': 'Thank you God.', 'childPrompt': 'Your turn'},
        'remember': {'memoryVerse': 'God is good.', 'ref': 'Genesis 1:1', 'memoryPhrase': 'good'},
        'doToday': {'action': 'Tell someone.'},
      },
    });

void main() {
  group('ContentManifest.parse', () {
    test('reads every collection and its entries', () {
      final manifest = ContentManifest.parse(
        _manifestJson([_item('a', 'v1'), _item('b', 'v2')]),
      );
      expect(manifest['stories'].map((e) => e.id), ['a', 'b']);
      expect(manifest['stories'].first.version, 'v1');
      expect(manifest['stories'].first.url, contains('/api/content/'));
    });

    test('skips a malformed entry instead of failing the whole manifest', () {
      final manifest = ContentManifest.parse(
        _manifestJson([
          _item('good', 'v1'),
          {'id': 'no-version', 'url': 'https://x/y'},
          {'version': 'v1', 'url': 'https://x/y'},
        ]),
      );
      expect(manifest['stories'].map((e) => e.id), ['good']);
    });

    test('returns empty for junk rather than throwing', () {
      expect(ContentManifest.parse(null).collections, isEmpty);
      expect(ContentManifest.parse('nonsense').collections, isEmpty);
      expect(ContentManifest.parse({'content': 42}).collections, isEmpty);
    });

    test('namespaces version keys by collection so ids cannot collide', () {
      expect(ManifestEntry.versionKey('stories', 'x'), isNot(ManifestEntry.versionKey('activities', 'x')));
    });
  });

  group('ManifestDiff.compute', () {
    final remote = ContentManifest.parse(
      _manifestJson([_item('a', 'v1'), _item('b', 'v1'), _item('c', 'v1')]),
    )['stories'];

    test('returns everything when nothing is stored locally', () {
      final diff = ManifestDiff.compute(remote: remote, localVersions: const {});
      expect(diff.outdated.map((e) => e.id), ['a', 'b', 'c']);
    });

    test('returns nothing when every version already matches', () {
      final diff = ManifestDiff.compute(
        remote: remote,
        localVersions: const {'a': 'v1', 'b': 'v1', 'c': 'v1'},
      );
      expect(diff.isEmpty, isTrue);
    });

    test('returns only the entries whose version changed', () {
      final diff = ManifestDiff.compute(
        remote: remote,
        localVersions: const {'a': 'v1', 'b': 'v0', 'c': null},
      );
      expect(diff.outdated.map((e) => e.id), ['b', 'c']);
    });

    test('detects a rollback — versions are hashes, not an ordered sequence', () {
      // 'zzz' sorts after 'v1'. A comparison using `<` would miss this entirely,
      // leaving the child on content that was deliberately rolled back.
      final diff = ManifestDiff.compute(
        remote: remote,
        localVersions: const {'a': 'zzz', 'b': 'v1', 'c': 'v1'},
      );
      expect(diff.outdated.map((e) => e.id), ['a']);
    });
  });

  group('ContentStore', () {
    late Directory temp;
    late ContentStore store;

    setUp(() {
      temp = Directory.systemTemp.createTempSync('lb-content-store');
      store = ContentStore(root: temp);
    });
    tearDown(() => temp.deleteSync(recursive: true));

    test('commits a package and reads it back', () async {
      await store.commit('stories', 'a', utf8.encode(_validStory('a')));
      expect(await store.has('stories', 'a'), isTrue);
      expect(jsonDecode((await store.read('stories', 'a'))!)['id'], 'a');
    });

    test('returns null for a package that was never downloaded', () async {
      expect(await store.read('stories', 'missing'), isNull);
    });

    test('leaves the previous package intact when validation rejects new bytes', () async {
      await store.commit('stories', 'a', utf8.encode(_validStory('a', title: 'Original')));

      await expectLater(
        store.commit(
          'stories',
          'a',
          utf8.encode('{"truncated":'),
          validate: (contents) => ContentDownloader.validate('stories', contents),
        ),
        throwsA(isA<FormatException>()),
      );

      final surviving = jsonDecode((await store.read('stories', 'a'))!);
      expect(surviving['title'], 'Original');
    });

    test('removes the staged file when a commit fails', () async {
      await expectLater(
        store.commit(
          'stories',
          'a',
          utf8.encode('not json'),
          validate: (contents) => ContentDownloader.validate('stories', contents),
        ),
        throwsA(anything),
      );
      final leftovers = temp
          .listSync(recursive: true)
          .where((e) => e.path.endsWith(ContentStore.partSuffix));
      expect(leftovers, isEmpty);
    });

    test('sweeps staged files abandoned by a killed process', () async {
      await store.commit('stories', 'a', utf8.encode(_validStory('a')));
      final orphan = File('${temp.path}/content/stories/b.json${ContentStore.partSuffix}');
      orphan.writeAsStringSync('half a file');

      expect(await store.sweepPartials(), 1);
      expect(orphan.existsSync(), isFalse);
      expect(await store.has('stories', 'a'), isTrue);
    });
  });

  group('ContentDownloader', () {
    late Directory temp;
    late ContentStore store;
    late Map<String, String> recorded;

    setUp(() {
      temp = Directory.systemTemp.createTempSync('lb-downloader');
      store = ContentStore(root: temp);
      recorded = {};
    });
    tearDown(() => temp.deleteSync(recursive: true));

    ContentDownloader downloader(ContentFetcher fetch) => ContentDownloader(
          store: store,
          fetch: fetch,
          recordVersion: (key, version) async => recorded[key] = version,
        );

    ManifestDiff diffOf(List<Map<String, dynamic>> items) => ManifestDiff.compute(
          remote: ContentManifest.parse(_manifestJson(items))['stories'],
          localVersions: const {},
        );

    test('downloads, commits, and records the version', () async {
      final result = await downloader((url) async => utf8.encode(_validStory('a')))
          .download('stories', diffOf([_item('a', 'v1')]));

      expect(result.allSucceeded, isTrue);
      expect(await store.has('stories', 'a'), isTrue);
      expect(recorded['stories:a'], 'v1');
    });

    test('records no version when the payload is truncated', () async {
      final result = await downloader((url) async => utf8.encode('{"id": "a"'))
          .download('stories', diffOf([_item('a', 'v1')]));

      expect(result.failed.map((e) => e.id), ['a']);
      // The rollback boundary: nothing recorded means the next manifest check
      // still sees this package as outdated and downloads it again cleanly.
      expect(recorded, isEmpty);
      expect(await store.has('stories', 'a'), isFalse);
    });

    test('records no version when the payload is valid JSON but not a story', () async {
      final result = await downloader((url) async => utf8.encode('{"unexpected": true}'))
          .download('stories', diffOf([_item('a', 'v1')]));

      expect(result.failed.map((e) => e.id), ['a']);
      expect(recorded, isEmpty);
    });

    test('records no version when the response is empty', () async {
      final result = await downloader((url) async => <int>[])
          .download('stories', diffOf([_item('a', 'v1')]));

      expect(result.failed.map((e) => e.id), ['a']);
      expect(recorded, isEmpty);
    });

    test('one failure does not abandon the rest of the batch', () async {
      final result = await downloader((url) async {
        if (url.contains('/b/')) throw const SocketException('offline');
        final id = url.split('/')[url.split('/').length - 2];
        return utf8.encode(_validStory(id));
      }).download('stories', diffOf([_item('a', 'v1'), _item('b', 'v1'), _item('c', 'v1')]));

      expect(result.succeeded.map((e) => e.id), ['a', 'c']);
      expect(result.failed.map((e) => e.id), ['b']);
      expect(recorded.keys, containsAll(['stories:a', 'stories:c']));
      expect(recorded.containsKey('stories:b'), isFalse);
    });

    test('a re-download after a failure completes cleanly', () async {
      var failNext = true;
      final downloads = downloader((url) async {
        if (failNext) {
          failNext = false;
          return utf8.encode('{"truncated"');
        }
        return utf8.encode(_validStory('a'));
      });

      await downloads.download('stories', diffOf([_item('a', 'v1')]));
      expect(recorded, isEmpty);

      final retry = await downloads.download('stories', diffOf([_item('a', 'v1')]));
      expect(retry.allSucceeded, isTrue);
      expect(recorded['stories:a'], 'v1');
      expect(jsonDecode((await store.read('stories', 'a'))!)['id'], 'a');
    });

    test('stops mid-batch when a story session starts, leaving the rest outdated', () async {
      var sessionStarted = false;
      final result = await downloader((url) async {
        sessionStarted = true; // the child opens a story after the first download
        return utf8.encode(_validStory('a'));
      }).download(
        'stories',
        diffOf([_item('a', 'v1'), _item('b', 'v1'), _item('c', 'v1')]),
        shouldContinue: () => !sessionStarted,
      );

      expect(result.succeeded.map((e) => e.id), ['a']);
      expect(result.failed.map((e) => e.id), ['b', 'c']);
      expect(recorded.keys, ['stories:a']);
    });
  });
}
