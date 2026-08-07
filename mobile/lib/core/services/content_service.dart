import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/story_model.dart';
import '../models/activity_model.dart';
import 'content_store.dart';
import 'content_update_service.dart';

part 'content_service.g.dart';

// Explicit curriculum order — controls the sequence children see stories.
// Matches LITTLE_BIBLE_COMPLETE_CURRICULUM.md story numbers exactly.
// Any story JSON in assets/stories/ that is NOT listed here is still loadable
// by ID (e.g. via a deep link) but won't appear in the main feed.
const _curriculumOrder = [
  // World 1 — In the Beginning (#1–8)
  'god-made-everything',              // #1
  'god-made-me',                      // #2
  'the-first-family',                 // #3
  'the-very-sad-choice',              // #4
  'god-promises-a-rescuer',           // #5
  'two-brothers',                     // #6
  'noahs-big-boat',                   // #7
  'noahs-rainbow-promise',            // #8
  // World 2 — Promise Family (#9–16)
  'the-tall-tower',                   // #9
  'god-calls-abraham',                // #10
  'stars-in-the-sky',                 // #11
  'the-promised-son',                 // #12
  'god-provides-a-lamb',              // #13
  'jacob-learns-grace',               // #14
  'joseph-and-his-brothers',          // #15
  'joseph-forgives-his-family',       // #16
  // World 3 — God Rescues a People (#17–24)
  'baby-moses-is-kept-safe',          // #17
  'god-calls-from-the-fire',          // #18
  'let-my-people-go',                 // #19
  'the-passover-lamb',                // #20
  'a-way-through-the-sea',            // #21
  'bread-in-the-wilderness',          // #22
  'gods-good-commands',               // #23
  'god-lives-with-his-people',        // #24
  // World 4 — A Land Needing a King (#25–32)
  'twelve-spies',                     // #25
  'joshua-and-the-walls',             // #26
  'deborah-leads-gods-people',        // #27
  'gideons-tiny-army',                // #28
  'ruth-finds-a-home',                // #29
  'samuel-listens-to-god',            // #30
  'saul-the-king',                    // #31
  'david-the-shepherd-boy',           // #32
  // World 5 — Heroes of Faith (#33–40)
  'david-and-the-giant',              // #33
  'davids-sin-and-gods-mercy',        // #34
  'gods-forever-king-promise',        // #35
  'solomon-asks-for-wisdom',          // #36
  'elijah-and-the-only-true-god',     // #37
  'jonah-and-the-big-fish',           // #38
  'daniel-and-the-lions',             // #39
  'the-prophets-promise-new-hearts',  // #40
  // World 6 — Jesus Is Here (#41–48)
  'an-angel-visits-mary',             // #41
  'birth-of-jesus',                   // #42
  'visitors-worship-the-king',        // #43
  'jesus-grows-and-obeys',            // #44
  'jesus-is-baptised',                // #45
  'jesus-says-no-to-tempter',         // #46
  'jesus-calls-his-helpers',          // #47
  'jesus-loves-children',             // #48
  // World 7 — The Compassionate King (#49–56)
  'jesus-calms-the-storm',            // #49
  'jesus-heals-and-forgives',         // #50
  'jesus-feeds-the-crowd',            // #51
  'the-good-neighbour',               // #52
  'the-lost-sheep',                   // #53
  'the-lost-son',                     // #54
  'how-to-pray',                      // #55
  'the-good-shepherd',                // #56
  // World 8 — Jesus Saves (#57–64)
  'jesus-raises-lazarus',             // #57
  'the-king-rides-in',                // #58
  'servant-king-washes-feet',         // #59
  'the-last-supper',                  // #60
  'jesus-prays-in-garden',            // #61
  'jesus-dies-for-sinners',           // #62
  'jesus-is-alive',                   // #63
  'jesus-saves',                      // #64
  // World 9 — Spirit-Filled Family (#65–72)
  'jesus-returns-to-his-father',      // #65
  'the-holy-spirit-comes',            // #66
  'a-new-sharing-family',             // #67
  'stephen-sees-jesus',               // #68
  'saul-meets-the-risen-jesus',       // #69
  'peter-welcomes-cornelius',         // #70
  'paul-and-silas-in-prison',         // #71
  'the-spirit-grows-good-fruit',      // #72
  // World 10 — The King Makes All Things New (#73–80)
  'gods-armour-for-hard-days',        // #73
  'when-anger-knocks',                // #74
  'when-i-feel-alone',                // #75
  'when-life-feels-unfair',           // #76
  'when-someone-we-love-dies',        // #77
  'jesus-will-come-again',            // #78
  'the-king-judges',                  // #79
  'god-makes-everything-new',         // #80
];

/// Whether [tier] needs a grown-up present for a child in [ageBand].
///
/// Returns false — no gate — when the parent has already approved guided
/// content for this child via [allowGuided] (the Parent Hub toggle).
///
/// `parental_presence` is the heaviest tier (currently only "When Someone We
/// Love Dies") and always asks, for every band below `independent`, regardless
/// of the toggle. That story should not open by accident.
bool storyNeedsGrownUp({
  required String tier,
  required String ageBand,
  required bool allowGuided,
}) {
  switch (tier) {
    case 'parental_presence':
      return ageBand != 'independent';
    case 'guided':
      if (allowGuided) return false;
      return ageBand == 'early';
    default:
      return false;
  }
}

@Riverpod(keepAlive: true)
ContentService contentService(Ref ref) => ContentService(ref.watch(contentStoreProvider));

class ContentService {
  ContentService([this._store]);

  /// Downloaded content, when present, wins over the bundled copy — that is what
  /// lets a published correction reach children without an app store release
  /// (US-12). Null in tests and any context with no on-device store.
  final ContentStore? _store;

  /// Reads a package, preferring the OTA-downloaded copy and falling back to the
  /// bundled asset. A downloaded file that fails to parse is ignored rather than
  /// breaking the story — the bundled copy is always a valid answer.
  Future<String?> _readDownloaded(String collection, String id) async {
    if (_store == null) return null;
    try {
      return await _store.read(collection, id);
    } catch (_) {
      return null;
    }
  }

  Future<StoryModel> loadStory(String storyId) async {
    final downloaded = await _readDownloaded('stories', storyId);
    if (downloaded != null) {
      try {
        return StoryModel.fromJson(jsonDecode(downloaded) as Map<String, dynamic>);
      } catch (_) {
        // Fall through to the bundled copy.
      }
    }
    final raw = await rootBundle.loadString('assets/stories/$storyId.json');
    return StoryModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  /// Every story in the curriculum, in order — nothing filtered out.
  ///
  /// This deliberately does NOT drop stories above the child's age band any
  /// more. It used to, and because the caller never passed an `ageBand` the
  /// default `'early'` applied to everyone, so 31 of the 80 stories — including
  /// the crucifixion — were invisible to every user with no explanation and no
  /// way for a parent to opt in. Age sensitivity is now handled at the point of
  /// opening a story (see [storyNeedsGrownUp]), where a parent can actually be
  /// asked, instead of silently deleting content from the map.
  Future<List<StoryModel>> loadAllStories() async {
    return Future.wait(_curriculumOrder.map(loadStory));
  }

  Future<ActivityModel?> loadActivity(String storyId) async {
    final downloaded = await _readDownloaded('activities', storyId);
    if (downloaded != null) {
      try {
        return ActivityModel.fromJson(jsonDecode(downloaded) as Map<String, dynamic>);
      } catch (_) {
        // Fall through to the bundled copy.
      }
    }
    try {
      final raw = await rootBundle.loadString('assets/activities/$storyId.json');
      return ActivityModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
