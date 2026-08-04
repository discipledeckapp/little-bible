import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/app_database.dart';
import '../providers/database_provider.dart';
import '../providers/profile_provider.dart';

part 'story_progress_repository.g.dart';

@riverpod
StoryProgressRepository storyProgressRepository(Ref ref) {
  return StoryProgressRepository(
    ref.watch(databaseProvider),
    ref.watch(profileRepositoryProvider),
  );
}

/// Live set of completed story IDs for a given profile.
@riverpod
Stream<Set<String>> completedStoryIds(Ref ref, String profileId) {
  return ref.watch(storyProgressRepositoryProvider).watchCompletedStoryIds(profileId);
}

/// Live set of story IDs this profile has *opened* — started or completed.
///
/// This is the free-allowance meter: the child may consume any
/// [kFreeStoryAllowance] stories they choose, in any order. See
/// [storyPaywallLocked].
@riverpod
Stream<Set<String>> consumedStoryIds(Ref ref, String profileId) {
  return ref.watch(storyProgressRepositoryProvider).watchConsumedStoryIds(profileId);
}

/// How many stories a child may open before the unlock purchase is required.
const kFreeStoryAllowance = 20;

/// Whether [storyId] is behind the paywall for this profile.
///
/// The allowance is **consumption-based, not positional**: any 20 stories the
/// child opens are free, whichever they pick. Deliberately NOT "the first 20 in
/// curriculum order" — that rule silently paywalled the gospel as soon as Old
/// Testament worlds were inserted ahead of the Jesus stories.
///
/// A story already opened never becomes locked again, so access is never revoked
/// once given. The standalone Bible reader is not gated at all.
bool storyPaywallLocked({
  required String storyId,
  required bool profileUnlocked,
  required Set<String> consumedIds,
}) {
  if (profileUnlocked) return false;
  if (consumedIds.contains(storyId)) return false;
  return consumedIds.length >= kFreeStoryAllowance;
}

class StoryProgressRepository {
  StoryProgressRepository(this._db, this._profileRepo);

  final AppDatabase _db;
  final ProfileRepository _profileRepo;

  Future<StoryProgressData?> getProgress(String profileId, String storyId) {
    return (_db.select(_db.storyProgress)
          ..where((t) => t.profileId.equals(profileId) & t.storyId.equals(storyId)))
        .getSingleOrNull();
  }

  /// Upsert the current scene index without touching status or seedsEarned.
  Future<void> saveScene(String profileId, String storyId, int sceneIndex) async {
    final updated = await (_db.update(_db.storyProgress)
          ..where((t) => t.profileId.equals(profileId) & t.storyId.equals(storyId)))
        .write(StoryProgressCompanion(lastSceneIndex: Value(sceneIndex)));

    if (updated == 0) {
      await _db.into(_db.storyProgress).insert(
        StoryProgressCompanion(
          profileId: Value(profileId),
          storyId: Value(storyId),
          lastSceneIndex: Value(sceneIndex),
        ),
      );
    }
  }

  /// Live stream of completed story IDs for a profile.
  Stream<Set<String>> watchCompletedStoryIds(String profileId) {
    return (_db.select(_db.storyProgress)
          ..where((t) =>
              t.profileId.equals(profileId) & t.status.equals('completed')))
        .watch()
        .map((rows) => rows.map((r) => r.storyId).toSet());
  }

  /// Live stream of every story ID this profile has opened (any status).
  Stream<Set<String>> watchConsumedStoryIds(String profileId) {
    return (_db.select(_db.storyProgress)
          ..where((t) => t.profileId.equals(profileId)))
        .watch()
        .map((rows) => rows.map((r) => r.storyId).toSet());
  }

  Future<List<StoryProgressData>> allCompletedForProfile(String profileId) {
    return (_db.select(_db.storyProgress)
          ..where((t) =>
              t.profileId.equals(profileId) & t.status.equals('completed')))
        .get();
  }

  /// Mark a story as completed and award seeds.
  Future<void> markComplete(
    String profileId,
    String storyId, {
    int seedsEarned = 3,
  }) async {
    final now = DateTime.now();
    final updated = await (_db.update(_db.storyProgress)
          ..where((t) => t.profileId.equals(profileId) & t.storyId.equals(storyId)))
        .write(StoryProgressCompanion(
          status: const Value('completed'),
          seedsEarned: Value(seedsEarned),
          completedAt: Value(now),
        ));

    if (updated == 0) {
      await _db.into(_db.storyProgress).insert(
        StoryProgressCompanion(
          profileId: Value(profileId),
          storyId: Value(storyId),
          status: const Value('completed'),
          seedsEarned: Value(seedsEarned),
          completedAt: Value(now),
        ),
      );
    }

    // Credit seeds + update activeDaysThisWeek from real story data
    final profile = await (_db.select(_db.childProfiles)
          ..where((t) => t.id.equals(profileId)))
        .getSingleOrNull();
    if (profile != null) {
      await (_db.update(_db.childProfiles)
            ..where((t) => t.id.equals(profileId)))
          .write(ChildProfilesCompanion(seeds: Value(profile.seeds + seedsEarned)));
    }
    await _profileRepo.recordActiveDays(profileId, _db);
  }
}
