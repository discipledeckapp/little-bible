import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/story_model.dart';
import '../models/activity_model.dart';

part 'content_service.g.dart';

// Explicit curriculum order — controls the sequence children see stories.
// Matches LITTLE_BIBLE_COMPLETE_CURRICULUM.md story numbers exactly.
// Any story JSON in assets/stories/ that is NOT listed here is still loadable
// by ID (e.g. via a deep link) but won't appear in the main feed.
const _curriculumOrder = [
  // World 1 — In the Beginning (#1–8)
  'god-made-everything',       // #1
  'god-made-me',               // #2
  'noahs-big-boat',            // #7
  'noahs-rainbow-promise',     // #8
  // World 2 — Heroes of Faith (#32, #38, #39)
  'david-the-shepherd-boy',    // #32
  'jonah-and-the-big-fish',    // #38
  'daniel-and-the-lions',      // #39
  // World 3 — Jesus Is Here (#42, #48)
  'birth-of-jesus',            // #42
  'jesus-loves-children',      // #48
  // World 4 — Jesus Teaches (#52–56)
  'the-good-neighbour',        // #52
  'the-lost-sheep',            // #53
  'the-lost-son',              // #54
  'how-to-pray',               // #55
  'the-good-shepherd',         // #56
  // World 5 — Jesus Saves (#64)
  'jesus-saves',               // #64
];

@Riverpod(keepAlive: true)
ContentService contentService(Ref ref) => ContentService();

class ContentService {
  Future<StoryModel> loadStory(String storyId) async {
    final raw = await rootBundle.loadString('assets/stories/$storyId.json');
    return StoryModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<List<StoryModel>> loadAllStories({String ageBand = 'early'}) async {
    final stories = await Future.wait(_curriculumOrder.map(loadStory));
    return stories.where((s) => _allowedForBand(s, ageBand)).toList();
  }

  bool _allowedForBand(StoryModel story, String ageBand) {
    return switch (story.sensitivityTier) {
      'general' => true,
      'guided' => ageBand != 'early',
      'parental_presence' => ageBand == 'independent',
      _ => true,
    };
  }

  Future<ActivityModel?> loadActivity(String storyId) async {
    try {
      final raw = await rootBundle.loadString('assets/activities/$storyId.json');
      return ActivityModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
