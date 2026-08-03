import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/app_database.dart';
import 'database_provider.dart';

part 'verse_mastery_repository.g.dart';

@riverpod
VerseMasteryRepository verseMasteryRepository(Ref ref) =>
    VerseMasteryRepository(ref.watch(databaseProvider));

/// All tracked verses for a profile — used by Parent Hub and Bible Nav.
@riverpod
Stream<List<VerseMasteryData>> allVersesForProfile(Ref ref, String profileId) {
  return ref.watch(verseMasteryRepositoryProvider).watchAllVerses(profileId);
}

class VerseMasteryRepository {
  VerseMasteryRepository(this._db);
  final AppDatabase _db;

  // Stage progression order
  static const _stages = [
    'introduced',
    'recognised',
    'recalled',
    'understood',
    'growing_familiar',
  ];

  /// Record the verse as 'introduced' when first shown on KeyVerseScreen.
  /// No-ops if already at a later stage.
  Future<void> introduce(
    String profileId,
    String verseKey, {
    String verseRef = '',
    String storyId = '',
  }) async {
    final existing = await (_db.select(_db.verseMastery)
          ..where((t) =>
              t.profileId.equals(profileId) & t.verseKey.equals(verseKey)))
        .getSingleOrNull();

    if (existing != null) return;

    final nextReview = DateTime.now().add(const Duration(days: 2));
    await _db.into(_db.verseMastery).insert(VerseMasteryCompanion.insert(
          profileId: profileId,
          verseKey: verseKey,
          verseRef: Value(verseRef),
          storyId: Value(storyId),
          nextReviewDate: nextReview,
        ));
  }

  /// Return all verses due for review today (nextReviewDate ≤ now).
  /// Returns at most 1 — the oldest due verse per the plan spec.
  Future<VerseMasteryData?> oldestDueVerse(String profileId) async {
    final today = DateTime.now();
    final rows = await (_db.select(_db.verseMastery)
          ..where((t) =>
              t.profileId.equals(profileId) &
              t.nextReviewDate.isSmallerOrEqualValue(today))
          ..orderBy([(t) => OrderingTerm.asc(t.nextReviewDate)])
          ..limit(1))
        .get();
    return rows.isEmpty ? null : rows.first;
  }

  /// Advance the stage after a successful practice session.
  Future<void> advance(String profileId, String verseKey) async {
    final row = await (_db.select(_db.verseMastery)
          ..where((t) =>
              t.profileId.equals(profileId) & t.verseKey.equals(verseKey)))
        .getSingleOrNull();
    if (row == null) return;

    final currentIdx = _stages.indexOf(row.stage);
    final nextIdx = (currentIdx + 1).clamp(0, _stages.length - 1);
    final nextStage = _stages[nextIdx];

    final days = switch (nextStage) {
      'recognised'      => 4,
      'recalled'        => 10,
      'understood'      => 21,
      'growing_familiar' => 30,
      _                 => 2,
    };

    await (_db.update(_db.verseMastery)
          ..where((t) =>
              t.profileId.equals(profileId) & t.verseKey.equals(verseKey)))
        .write(VerseMasteryCompanion(
          stage: Value(nextStage),
          nextReviewDate: Value(DateTime.now().add(Duration(days: days))),
        ));
  }

  /// All verses tracked for this profile, newest first — used by Bible nav.
  Stream<List<VerseMasteryData>> watchAllVerses(String profileId) {
    return (_db.select(_db.verseMastery)
          ..where((t) => t.profileId.equals(profileId))
          ..orderBy([(t) => OrderingTerm.desc(t.id)]))
        .watch();
  }

  /// Soft-fail after an incorrect or skipped practice: reset nextReviewDate
  /// to tomorrow without regressing the stage.
  Future<void> softFail(String profileId, String verseKey) async {
    await (_db.update(_db.verseMastery)
          ..where((t) =>
              t.profileId.equals(profileId) & t.verseKey.equals(verseKey)))
        .write(VerseMasteryCompanion(
          nextReviewDate:
              Value(DateTime.now().add(const Duration(days: 1))),
        ));
  }
}
