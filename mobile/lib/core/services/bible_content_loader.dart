import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/app_database.dart';
import '../providers/database_provider.dart';

part 'bible_content_loader.g.dart';

@Riverpod(keepAlive: true)
BibleContentLoader bibleContentLoader(Ref ref) {
  final db = ref.watch(databaseProvider);
  return BibleContentLoader(db);
}

const _kBibleAssets = <String, List<String>>{
  'Genesis': [
    'assets/bible/en/genesis/genesis_chapter_01.json',
    'assets/bible/en/genesis/genesis_chapter_02.json',
    'assets/bible/en/genesis/genesis_chapter_03.json',
    'assets/bible/en/genesis/genesis_chapter_04.json',
    'assets/bible/en/genesis/genesis_chapter_05.json',
    'assets/bible/en/genesis/genesis_chapter_06.json',
    'assets/bible/en/genesis/genesis_chapter_07.json',
    'assets/bible/en/genesis/genesis_chapter_08.json',
    'assets/bible/en/genesis/genesis_chapter_09.json',
    'assets/bible/en/genesis/genesis_chapter_10.json',
    'assets/bible/en/genesis/genesis_chapter_11.json',
    'assets/bible/en/genesis/genesis_chapter_12.json',
    'assets/bible/en/genesis/genesis_chapter_13.json',
    'assets/bible/en/genesis/genesis_chapter_14.json',
    'assets/bible/en/genesis/genesis_chapter_15.json',
    'assets/bible/en/genesis/genesis_chapter_16.json',
    'assets/bible/en/genesis/genesis_chapter_17.json',
  ],
  'John': [
    'assets/bible/en/john/john_chapter_01.json',
    'assets/bible/en/john/john_chapter_02.json',
    'assets/bible/en/john/john_chapter_03.json',
    'assets/bible/en/john/john_chapter_04.json',
    'assets/bible/en/john/john_chapter_05.json',
    'assets/bible/en/john/john_chapter_06.json',
    'assets/bible/en/john/john_chapter_07.json',
    'assets/bible/en/john/john_chapter_08.json',
    'assets/bible/en/john/john_chapter_09.json',
    'assets/bible/en/john/john_chapter_10.json',
    'assets/bible/en/john/john_chapter_11.json',
    'assets/bible/en/john/john_chapter_12.json',
    'assets/bible/en/john/john_chapter_13.json',
    'assets/bible/en/john/john_chapter_14.json',
    'assets/bible/en/john/john_chapter_15.json',
    'assets/bible/en/john/john_chapter_16.json',
    'assets/bible/en/john/john_chapter_17.json',
    'assets/bible/en/john/john_chapter_18.json',
    'assets/bible/en/john/john_chapter_19.json',
    'assets/bible/en/john/john_chapter_20.json',
    'assets/bible/en/john/john_chapter_21.json',
  ],
  'Luke': [
    'assets/bible/en/luke/luke_chapter_01.json',
    'assets/bible/en/luke/luke_chapter_02.json',
    'assets/bible/en/luke/luke_chapter_03.json',
    'assets/bible/en/luke/luke_chapter_04.json',
    'assets/bible/en/luke/luke_chapter_05.json',
    'assets/bible/en/luke/luke_chapter_06.json',
    'assets/bible/en/luke/luke_chapter_10.json',
    'assets/bible/en/luke/luke_chapter_15.json',
    'assets/bible/en/luke/luke_chapter_22.json',
    'assets/bible/en/luke/luke_chapter_23.json',
    'assets/bible/en/luke/luke_chapter_24.json',
  ],
  'Mark': [
    'assets/bible/en/mark/mark_chapter_01.json',
    'assets/bible/en/mark/mark_chapter_02.json',
    'assets/bible/en/mark/mark_chapter_03.json',
    'assets/bible/en/mark/mark_chapter_04.json',
    'assets/bible/en/mark/mark_chapter_10.json',
  ],
  'Matthew': [
    'assets/bible/en/matthew/matthew_chapter_05.json',
    'assets/bible/en/matthew/matthew_chapter_06.json',
    'assets/bible/en/matthew/matthew_chapter_07.json',
    'assets/bible/en/matthew/matthew_chapter_08.json',
    'assets/bible/en/matthew/matthew_chapter_09.json',
    'assets/bible/en/matthew/matthew_chapter_27.json',
    'assets/bible/en/matthew/matthew_chapter_28.json',
  ],
  'Proverbs': [
    'assets/bible/en/proverbs/proverbs_chapter_01.json',
    'assets/bible/en/proverbs/proverbs_chapter_02.json',
    'assets/bible/en/proverbs/proverbs_chapter_03.json',
    'assets/bible/en/proverbs/proverbs_chapter_04.json',
    'assets/bible/en/proverbs/proverbs_chapter_05.json',
    'assets/bible/en/proverbs/proverbs_chapter_06.json',
    'assets/bible/en/proverbs/proverbs_chapter_07.json',
    'assets/bible/en/proverbs/proverbs_chapter_08.json',
    'assets/bible/en/proverbs/proverbs_chapter_09.json',
    'assets/bible/en/proverbs/proverbs_chapter_10.json',
    'assets/bible/en/proverbs/proverbs_chapter_11.json',
    'assets/bible/en/proverbs/proverbs_chapter_12.json',
    'assets/bible/en/proverbs/proverbs_chapter_13.json',
    'assets/bible/en/proverbs/proverbs_chapter_14.json',
    'assets/bible/en/proverbs/proverbs_chapter_15.json',
    'assets/bible/en/proverbs/proverbs_chapter_16.json',
    'assets/bible/en/proverbs/proverbs_chapter_17.json',
    'assets/bible/en/proverbs/proverbs_chapter_18.json',
    'assets/bible/en/proverbs/proverbs_chapter_19.json',
    'assets/bible/en/proverbs/proverbs_chapter_20.json',
    'assets/bible/en/proverbs/proverbs_chapter_21.json',
    'assets/bible/en/proverbs/proverbs_chapter_22.json',
    'assets/bible/en/proverbs/proverbs_chapter_23.json',
    'assets/bible/en/proverbs/proverbs_chapter_24.json',
    'assets/bible/en/proverbs/proverbs_chapter_25.json',
    'assets/bible/en/proverbs/proverbs_chapter_26.json',
    'assets/bible/en/proverbs/proverbs_chapter_27.json',
    'assets/bible/en/proverbs/proverbs_chapter_28.json',
    'assets/bible/en/proverbs/proverbs_chapter_29.json',
    'assets/bible/en/proverbs/proverbs_chapter_30.json',
    'assets/bible/en/proverbs/proverbs_chapter_31.json',
  ],
  'Psalms': [
    'assets/bible/en/psalms/psalms_chapter_01.json',
    'assets/bible/en/psalms/psalms_chapter_22.json',
    'assets/bible/en/psalms/psalms_chapter_23.json',
    'assets/bible/en/psalms/psalms_chapter_100.json',
    'assets/bible/en/psalms/psalms_chapter_121.json',
    'assets/bible/en/psalms/psalms_chapter_139.json',
    'assets/bible/en/psalms/psalms_chapter_150.json',
  ],
};

class BibleContentLoader {
  BibleContentLoader(this._db);

  final AppDatabase _db;

  Future<void> seed() async {
    if (await _db.isBibleSeeded()) return;

    for (final entry in _kBibleAssets.entries) {
      for (final assetPath in entry.value) {
        try {
          await _loadChapter(assetPath);
        } catch (_) {
          // A bad chapter should not abort the rest of seeding.
        }
      }
    }

    await _db.markBibleSeeded();
  }

  Future<void> _loadChapter(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;

    final book    = json['book']    as String;
    final chapter = json['chapter'] as int;

    final memVerse = json['memory_verse'] as Map<String, dynamic>?;

    await _db.into(_db.bibleChapters).insertOnConflictUpdate(
      BibleChaptersCompanion.insert(
        book:                   book,
        chapter:                chapter,
        chapterSummary:         drift.Value(json['chapter_summary'] as String?),
        mainLesson:             drift.Value(json['main_lesson'] as String?),
        memoryVerseRef:         drift.Value(memVerse?['ref'] as String?),
        memoryVerseLittleBible: drift.Value(memVerse?['little_bible'] as String?),
        parentGuide:            drift.Value(json['parent_guide'] as String?),
        applicationForChildren: drift.Value(json['application_for_children'] as String?),
      ),
    );

    final rawVerses = json['verses'] as List<dynamic>;
    for (final v in rawVerses) {
      final vMap    = v as Map<String, dynamic>;
      final lbv     = vMap['little_bible'] as String?;
      final verseNo = vMap['verse'] as int;

      await _db.into(_db.verses).insertOnConflictUpdate(
        VersesCompanion.insert(
          book:                   book,
          chapter:                chapter,
          verse:                  verseNo,
          body:                   lbv ?? '',
          source:                 const drift.Value('little-bible'),
          isAdapted:              const drift.Value(true),
          kjv:                    drift.Value(vMap['kjv'] as String?),
          littleBible:            drift.Value(lbv),
          littleReaderAdaptation: drift.Value(vMap['little_reader_adaptation'] as String?),
          meaning:                drift.Value(vMap['meaning'] as String?),
          memoryPhrase:           drift.Value(vMap['memory_phrase'] as String?),
          prayer:                 drift.Value(vMap['prayer'] as String?),
          discussionQuestion:     drift.Value(vMap['discussion_question'] as String?),
          familyDiscussion:       drift.Value(vMap['family_discussion'] as String?),
          doItToday:              drift.Value(vMap['do_it_today'] as String?),
        ),
      );
    }
  }
}
