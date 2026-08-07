import 'dart:convert';
import 'dart:math';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/bible_canon.dart';
import '../database/app_database.dart';
import '../providers/database_provider.dart';

part 'bible_content_loader.g.dart';

// LBV books — seeded first so familiar content appears within seconds.
const _kLbvBookKeys = {
  'genesis', 'john', 'luke', 'mark', 'matthew', 'proverbs', 'psalms',
};

@Riverpod(keepAlive: true)
BibleContentLoader bibleContentLoader(Ref ref) {
  final db = ref.watch(databaseProvider);
  return BibleContentLoader(db);
}

class _ChapterData {
  const _ChapterData(this.chapter, this.verses);
  final BibleChaptersCompanion chapter;
  final List<VersesCompanion> verses;
}

class BibleContentLoader {
  BibleContentLoader(this._db);

  final AppDatabase _db;

  // Compute all 1,189 chapter asset paths directly from the canon.
  // This is more reliable than parsing the AssetManifest, which can
  // return different path formats across Flutter versions and platforms.
  static List<String> _buildChapterPaths() {
    final lbv = <String>[];
    final rest = <String>[];
    for (final book in kBibleBooks) {
      for (int ch = 1; ch <= book.chapterCount; ch++) {
        final chPadded = ch.toString().padLeft(2, '0');
        final path =
            'assets/bible/en/${book.key}/${book.key}_chapter_$chPadded.json';
        if (_kLbvBookKeys.contains(book.key)) {
          lbv.add(path);
        } else {
          rest.add(path);
        }
      }
    }
    // LBV books first (already in canonical order within each group)
    return [...lbv, ...rest];
  }

  Future<void> seed() async {
    if (await _db.isBibleSeeded()) return;

    final all = _buildChapterPaths();

    // Clear existing rows first so we start fresh.
    await _db.delete(_db.verses).go();
    await _db.delete(_db.bibleChapters).go();

    // Load 40 files in parallel, then insert via a single Drift batch.
    // Parallel I/O: ~10× faster than sequential reads.
    // Batch insert: ~50× faster than individual awaited inserts.
    const sliceSize = 40;
    for (int i = 0; i < all.length; i += sliceSize) {
      final slice = all.sublist(i, min(i + sliceSize, all.length));
      final results = (await Future.wait(slice.map(_parseChapter)))
          .whereType<_ChapterData>()
          .toList();
      await _db.batch((b) {
        for (final r in results) {
          b.insert(_db.bibleChapters, r.chapter,
              mode: drift.InsertMode.insertOrReplace);
          b.insertAll(_db.verses, r.verses,
              mode: drift.InsertMode.insert);
        }
      });
    }

    await _db.markBibleSeeded();
  }

  Future<_ChapterData?> _parseChapter(String assetPath) async {
    try {
      return await _parseChapterInner(assetPath);
    } catch (e) {
      // Never abort the whole seed for one bad file — log and skip.
      debugPrint('BibleSeeder: skipped $assetPath — $e');
      return null;
    }
  }

  Future<_ChapterData> _parseChapterInner(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final map = jsonDecode(raw) as Map<String, dynamic>;

    final book    = map['book'] as String;
    final chapter = (map['chapter'] as num).toInt();

    // memory_verse can be a plain string, a {ref, kjv, little_bible} map, or absent.
    String? memVerseRef;
    String? memVerseLbv;
    final memVerseRaw = map['memory_verse'];
    if (memVerseRaw is Map<String, dynamic>) {
      memVerseRef = memVerseRaw['ref'] as String?;
      memVerseLbv = (memVerseRaw['little_bible'] ?? memVerseRaw['kjv']) as String?;
    } else if (memVerseRaw is String && memVerseRaw.isNotEmpty) {
      memVerseLbv = memVerseRaw;
    }

    final chapterRow = BibleChaptersCompanion.insert(
      book: book,
      chapter: chapter,
      chapterSummary: drift.Value(map['chapter_summary'] as String?),
      mainLesson: drift.Value(map['main_lesson'] as String?),
      memoryVerseRef: drift.Value(memVerseRef),
      memoryVerseLittleBible: drift.Value(memVerseLbv),
      parentGuide: drift.Value(map['parent_guide'] as String?),
      applicationForChildren:
          drift.Value(map['application_for_children'] as String?),
    );

    final rawVerses = map['verses'] as List<dynamic>;
    final verseRows = rawVerses.map((v) {
      final vMap    = v as Map<String, dynamic>;
      final lbv     = vMap['little_bible'] as String?;
      final kjv     = vMap['kjv'] as String?;
      final verseNo = (vMap['verse'] as num).toInt();

      return VersesCompanion.insert(
        book:    book,
        chapter: chapter,
        verse:   verseNo,
        body:    lbv ?? kjv ?? '',
        source:  drift.Value(lbv == null ? 'kjv' : 'little-bible'),
        isAdapted: drift.Value(lbv != null),
        kjv:     drift.Value(kjv),
        littleBible: lbv == null
            ? const drift.Value(null)
            : drift.Value(lbv),
        littleReaderAdaptation:
            drift.Value(vMap['little_reader_adaptation'] as String?),
        meaning:           drift.Value(vMap['meaning'] as String?),
        memoryPhrase:      drift.Value(vMap['memory_phrase'] as String?),
        prayer:            drift.Value(vMap['prayer'] as String?),
        discussionQuestion:
            drift.Value(vMap['discussion_question'] as String?),
        familyDiscussion:  drift.Value(vMap['family_discussion'] as String?),
        doItToday:         drift.Value(vMap['do_it_today'] as String?),
      );
    }).toList();

    return _ChapterData(chapterRow, verseRows);
  }
}
