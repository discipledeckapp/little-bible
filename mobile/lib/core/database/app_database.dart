import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// ─── Tables ──────────────────────────────────────────────────────────────────

class Verses extends Table {
  IntColumn  get id      => integer().autoIncrement()();
  TextColumn get book    => text()();
  IntColumn  get chapter => integer()();
  IntColumn  get verse   => integer()();
  // The column is named 'body' to avoid shadowing Drift's Table.text() builder.
  TextColumn get body    => text()();
  // 'little-bible' | 'web'
  TextColumn get source    => text().withDefault(Constant('web'))();
  BoolColumn get isAdapted => boolean().withDefault(Constant(false))();

  // Bible reader fields (nullable — added in schema v4)
  TextColumn get kjv                    => text().nullable()();
  TextColumn get littleBible            => text().nullable()();
  TextColumn get littleReaderAdaptation => text().nullable()();
  TextColumn get meaning                => text().nullable()();
  TextColumn get memoryPhrase           => text().nullable()();
  TextColumn get prayer                 => text().nullable()();
  TextColumn get discussionQuestion     => text().nullable()();
  TextColumn get familyDiscussion       => text().nullable()();
  TextColumn get doItToday              => text().nullable()();
}

class BibleChapters extends Table {
  TextColumn get book                    => text()();
  IntColumn  get chapter                 => integer()();
  TextColumn get chapterSummary          => text().nullable()();
  TextColumn get mainLesson              => text().nullable()();
  TextColumn get memoryVerseRef          => text().nullable()();
  TextColumn get memoryVerseLittleBible  => text().nullable()();
  TextColumn get parentGuide             => text().nullable()();
  TextColumn get applicationForChildren  => text().nullable()();

  @override
  Set<Column> get primaryKey => {book, chapter};
}

class ChildProfiles extends Table {
  TextColumn get id         => text().clientDefault(() => _uuid())();
  TextColumn get nickname   => text()();
  // 'early' | 'emerging' | 'independent'
  TextColumn get ageBand    => text()();
  // 'lion' | 'lamb' | 'dove' | 'bear'
  TextColumn get avatarId   => text().withDefault(const Constant('lion'))();
  IntColumn  get seeds      => integer().withDefault(const Constant(0))();
  // raw streak number — shown only in parent hub, never to child
  IntColumn  get streakDays => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastActiveDate => dateTime().nullable()();
  BoolColumn get isUnlocked => boolean().withDefault(const Constant(false))();
  BoolColumn get hasSeenIntro => boolean().withDefault(const Constant(false))();
  // JSON array of earned badge IDs
  TextColumn get badgesJson => text().withDefault(const Constant('[]'))();
  // 'active' is the currently selected child; there can be multiple profiles
  BoolColumn get isActive   => boolean().withDefault(const Constant(false))();
  BoolColumn get autoplayEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get quietStoryMode => boolean().withDefault(const Constant(false))();
  BoolColumn get musicEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get effectsEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get notificationsEnabled => boolean().withDefault(const Constant(false))();
  BoolColumn get reducedMotion => boolean().withDefault(const Constant(false))();
  BoolColumn get wifiOnlyDownloads => boolean().withDefault(const Constant(true))();
  BoolColumn get cloudSyncEnabled => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class StoryProgress extends Table {
  TextColumn get profileId      => text()();
  TextColumn get storyId        => text()();
  IntColumn  get lastSceneIndex => integer().withDefault(Constant(0))();
  // 'in_progress' | 'completed'
  TextColumn get status         => text().withDefault(Constant('in_progress'))();
  IntColumn  get gameScore      => integer().withDefault(Constant(0))();
  IntColumn  get seedsEarned    => integer().withDefault(Constant(0))();
  DateTimeColumn get startedAt  => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {profileId, storyId};
}

class VerseMastery extends Table {
  IntColumn  get id         => integer().autoIncrement()();
  TextColumn get profileId  => text()();
  // e.g. 'genesis-1-1'
  TextColumn get verseKey   => text()();
  // Human-readable ref for display: "Genesis 6:22"
  TextColumn get verseRef   => text().withDefault(const Constant(''))();
  // The story this verse belongs to — used for navigation from home card
  TextColumn get storyId    => text().withDefault(const Constant(''))();
  // 'introduced' | 'recognised' | 'recalled' | 'understood' | 'growing_familiar'
  TextColumn get stage      => text().withDefault(const Constant('introduced'))();
  DateTimeColumn get nextReviewDate => dateTime()();
  DateTimeColumn get masteredAt     => dateTime().nullable()();
}

class SyncQueue extends Table {
  IntColumn  get id        => integer().autoIncrement()();
  TextColumn get profileId => text()();
  // 'progress' | 'verse_mastery' | 'unlock'
  TextColumn get operation => text()();
  // JSON payload — minimised, no PII, uses random profile ID
  TextColumn get payload   => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get syncedAt  => dateTime().nullable()();
}

class ContentVersions extends Table {
  TextColumn get contentType => text()();  // 'stories' | 'activities' | 'verses'
  TextColumn get version     => text()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {contentType};
}

// ─── Database ─────────────────────────────────────────────────────────────────

@DriftDatabase(tables: [
  Verses,
  BibleChapters,
  ChildProfiles,
  StoryProgress,
  VerseMastery,
  SyncQueue,
  ContentVersions,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 4;

  // ─── Sync Queue DAOs ─────────────────────────────────────────────────────────

  /// Returns all SyncQueue rows where syncedAt is null and operation = 'progress'.
  Future<List<SyncQueueData>> getPendingSyncEntries() {
    return (select(syncQueue)
          ..where((t) => t.syncedAt.isNull() & t.operation.equals('progress')))
        .get();
  }

  /// Stamps syncedAt = now on the given row IDs (called after a successful POST).
  Future<void> markSyncEntriesSynced(List<int> ids) {
    if (ids.isEmpty) return Future.value();
    return (update(syncQueue)..where((t) => t.id.isIn(ids)))
        .write(SyncQueueCompanion(syncedAt: Value(DateTime.now())));
  }

  // ─── Content Version DAOs ────────────────────────────────────────────────────

  /// Returns the stored version string for a given storyId, or null if unseen.
  Future<String?> getContentVersion(String storyId) async {
    final row = await (select(contentVersions)
          ..where((t) => t.contentType.equals(storyId)))
        .getSingleOrNull();
    return row?.version;
  }

  /// Upserts the version record for a storyId.
  Future<void> upsertContentVersion(String storyId, String version) {
    return into(contentVersions).insertOnConflictUpdate(
      ContentVersionsCompanion.insert(
        contentType: storyId,
        version: version,
      ),
    );
  }

  // ─── Bible Reader DAOs ───────────────────────────────────────────────────────

  Future<List<BibleChapter>> getLoadedChapters(String book) {
    return (select(bibleChapters)
          ..where((t) => t.book.equals(book))
          ..orderBy([(t) => OrderingTerm.asc(t.chapter)]))
        .get();
  }

  Future<List<Verse>> getChapterVerses(String book, int chapter) {
    return (select(verses)
          ..where((t) => t.book.equals(book) & t.chapter.equals(chapter))
          ..orderBy([(t) => OrderingTerm.asc(t.verse)]))
        .get();
  }

  Future<bool> isBibleSeeded() async {
    final row = await (select(contentVersions)
          ..where((t) => t.contentType.equals('bible_v2')))
        .getSingleOrNull();
    return row != null;
  }

  Future<void> markBibleSeeded() {
    return into(contentVersions).insertOnConflictUpdate(
      ContentVersionsCompanion.insert(
        contentType: 'bible_v2',
        version: '1.0',
      ),
    );
  }

  // ─── User Data ───────────────────────────────────────────────────────────────

  /// Wipes all child-owned data (profiles, progress, verse mastery, sync queue).
  /// Leaves Verses and ContentVersions intact — those are content, not user data.
  Future<void> deleteAllUserData() async {
    await transaction(() async {
      await delete(childProfiles).go();
      await delete(storyProgress).go();
      await delete(verseMastery).go();
      await delete(syncQueue).go();
    });
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // v1 → v2: added verseRef + storyId to VerseMastery for display/navigation
        await m.addColumn(verseMastery, verseMastery.verseRef);
        await m.addColumn(verseMastery, verseMastery.storyId);
      }
      if (from < 3) {
        await m.addColumn(childProfiles, childProfiles.autoplayEnabled);
        await m.addColumn(childProfiles, childProfiles.quietStoryMode);
        await m.addColumn(childProfiles, childProfiles.musicEnabled);
        await m.addColumn(childProfiles, childProfiles.effectsEnabled);
        await m.addColumn(childProfiles, childProfiles.notificationsEnabled);
        await m.addColumn(childProfiles, childProfiles.reducedMotion);
        await m.addColumn(childProfiles, childProfiles.wifiOnlyDownloads);
        await m.addColumn(childProfiles, childProfiles.cloudSyncEnabled);
      }
      if (from < 4) {
        await m.createTable(bibleChapters);
        await m.addColumn(verses, verses.kjv);
        await m.addColumn(verses, verses.littleBible);
        await m.addColumn(verses, verses.littleReaderAdaptation);
        await m.addColumn(verses, verses.meaning);
        await m.addColumn(verses, verses.memoryPhrase);
        await m.addColumn(verses, verses.prayer);
        await m.addColumn(verses, verses.discussionQuestion);
        await m.addColumn(verses, verses.familyDiscussion);
        await m.addColumn(verses, verses.doItToday);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA journal_mode = WAL');
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir  = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'little_bible.db'));
    return NativeDatabase(file);
  });
}

// Simple UUID v4 without external dep (uses dart:math randomness)
String _uuid() {
  final now = DateTime.now().microsecondsSinceEpoch;
  return 'lb-$now';
}
