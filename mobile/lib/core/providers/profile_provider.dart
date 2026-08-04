import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/app_database.dart';
import 'database_provider.dart';

part 'profile_provider.g.dart';

// ─── Active profile ───────────────────────────────────────────────────────────

@riverpod
Stream<ChildProfile?> activeProfile(Ref ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.childProfiles)
        ..where((t) => t.isActive.equals(true)))
      .watchSingleOrNull();
}

@riverpod
bool hasActiveProfile(Ref ref) {
  return ref.watch(activeProfileProvider).valueOrNull != null;
}

@riverpod
Stream<List<ChildProfile>> allProfiles(Ref ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.childProfiles).watch();
}

// ─── Profile repository ───────────────────────────────────────────────────────

@riverpod
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepository(ref.watch(databaseProvider));
}

class ProfileRepository {
  ProfileRepository(this._db);

  final AppDatabase _db;

  Future<ChildProfile> create({
    required String nickname,
    required String ageBand,
    required String avatarId,
  }) async {
    await (_db.update(_db.childProfiles)
          ..where((t) => t.isActive.equals(true)))
        .write(const ChildProfilesCompanion(isActive: Value(false)));

    final companion = ChildProfilesCompanion.insert(
      nickname: nickname,
      ageBand:  ageBand,
      avatarId: Value(avatarId),
      isActive: const Value(true),
    );
    await _db.into(_db.childProfiles).insert(companion);

    return (_db.select(_db.childProfiles)
          ..where((t) => t.isActive.equals(true)))
        .getSingle();
  }

  Future<void> markIntroSeen(String profileId) async {
    await (_db.update(_db.childProfiles)
          ..where((t) => t.id.equals(profileId)))
        .write(const ChildProfilesCompanion(hasSeenIntro: Value(true)));
  }

  Future<void> addSeeds(String profileId, int seeds) async {
    final current = await (_db.select(_db.childProfiles)
          ..where((t) => t.id.equals(profileId)))
        .getSingle();
    await (_db.update(_db.childProfiles)
          ..where((t) => t.id.equals(profileId)))
        .write(ChildProfilesCompanion(seeds: Value(current.seeds + seeds)));
  }

  /// Records that the profile was active today and updates streakDays to the
  /// count of distinct calendar days with story activity in the last 7 days.
  /// Driven by story_progress.completedAt, so it reflects real engagement.
  Future<void> recordActiveDays(String profileId, AppDatabase db) async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    // Filter by profileId only; completedAt being non-null already implies 'completed'.
    final rows = await (db.select(db.storyProgress)
          ..where((t) => t.profileId.equals(profileId)))
        .get();

    final distinctDays = rows
        .where((r) => r.completedAt != null && r.completedAt!.isAfter(weekAgo))
        .map((r) {
          final d = r.completedAt!;
          return DateTime(d.year, d.month, d.day);
        })
        .toSet()
        .length;

    await (_db.update(_db.childProfiles)
          ..where((t) => t.id.equals(profileId)))
        .write(ChildProfilesCompanion(
          streakDays: Value(distinctDays),
          lastActiveDate: Value(now),
        ));
  }

  Future<void> setUnlocked(String profileId) async {
    await (_db.update(_db.childProfiles)
          ..where((t) => t.id.equals(profileId)))
        .write(const ChildProfilesCompanion(isUnlocked: Value(true)));
  }

  /// Marks every profile on this device as unlocked.
  /// Called on purchase and on each app start when the device-unlock flag is set,
  /// so profiles created after the original purchase are caught automatically.
  Future<void> setAllUnlocked() async {
    await _db
        .update(_db.childProfiles)
        .write(const ChildProfilesCompanion(isUnlocked: Value(true)));
  }

  Future<void> updateSettings(
    String profileId, {
    bool? autoplayEnabled,
    bool? quietStoryMode,
    bool? musicEnabled,
    bool? effectsEnabled,
    bool? notificationsEnabled,
    bool? reducedMotion,
    bool? wifiOnlyDownloads,
    bool? cloudSyncEnabled,
  }) async {
    await (_db.update(_db.childProfiles)..where((t) => t.id.equals(profileId)))
        .write(ChildProfilesCompanion(
      autoplayEnabled: autoplayEnabled == null ? const Value.absent() : Value(autoplayEnabled),
      quietStoryMode: quietStoryMode == null ? const Value.absent() : Value(quietStoryMode),
      musicEnabled: musicEnabled == null ? const Value.absent() : Value(musicEnabled),
      effectsEnabled: effectsEnabled == null ? const Value.absent() : Value(effectsEnabled),
      notificationsEnabled: notificationsEnabled == null ? const Value.absent() : Value(notificationsEnabled),
      reducedMotion: reducedMotion == null ? const Value.absent() : Value(reducedMotion),
      wifiOnlyDownloads: wifiOnlyDownloads == null ? const Value.absent() : Value(wifiOnlyDownloads),
      cloudSyncEnabled: cloudSyncEnabled == null ? const Value.absent() : Value(cloudSyncEnabled),
    ));
  }

  Future<List<ChildProfile>> all() => _db.select(_db.childProfiles).get();

  /// Convenience alias for [all].
  Future<List<ChildProfile>> getAllProfiles() => all();

  /// Convenience alias for [switchActive].
  Future<void> setActiveProfile(String profileId) => switchActive(profileId);

  /// Creates an additional profile using an emoji string as the avatar identifier.
  Future<ChildProfile> createProfile({
    required String nickname,
    required String ageBand,
    required String avatarEmoji,
  }) =>
      create(nickname: nickname, ageBand: ageBand, avatarId: avatarEmoji);

  /// Permanently removes a profile and all its associated progress data.
  Future<void> deleteProfile(String profileId) async {
    await _db.transaction(() async {
      await (_db.delete(_db.storyProgress)
            ..where((t) => t.profileId.equals(profileId)))
          .go();
      await (_db.delete(_db.verseMastery)
            ..where((t) => t.profileId.equals(profileId)))
          .go();
      await (_db.delete(_db.syncQueue)
            ..where((t) => t.profileId.equals(profileId)))
          .go();
      await (_db.delete(_db.childProfiles)
            ..where((t) => t.id.equals(profileId)))
          .go();
    });
  }

  Future<void> editProfile(
    String profileId, {
    required String nickname,
    required String ageBand,
    required String avatarId,
  }) {
    return (_db.update(_db.childProfiles)
          ..where((t) => t.id.equals(profileId)))
        .write(ChildProfilesCompanion(
      nickname: Value(nickname),
      ageBand:  Value(ageBand),
      avatarId: Value(avatarId),
    ));
  }

  Future<void> switchActive(String profileId) async {
    await _db.transaction(() async {
      await (_db.update(_db.childProfiles)
            ..where((t) => t.isActive.equals(true)))
          .write(const ChildProfilesCompanion(isActive: Value(false)));
      await (_db.update(_db.childProfiles)
            ..where((t) => t.id.equals(profileId)))
          .write(const ChildProfilesCompanion(isActive: Value(true)));
    });
  }
}
