import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/story_model.dart';
import '../../../core/models/activity_model.dart';
import '../../../core/services/content_service.dart';
import '../../../core/services/content_session.dart';

part 'story_provider.g.dart';

// Each of these watches contentRevisionProvider so a finished OTA download
// refreshes the story in place, without an app restart (US-12).

@riverpod
Future<StoryModel> story(Ref ref, String storyId) {
  ref.watch(contentRevisionProvider);
  return ref.read(contentServiceProvider).loadStory(storyId);
}

@riverpod
Future<List<StoryModel>> allStories(Ref ref) {
  ref.watch(contentRevisionProvider);
  return ref.read(contentServiceProvider).loadAllStories();
}

@riverpod
Future<ActivityModel?> storyActivity(Ref ref, String storyId) {
  ref.watch(contentRevisionProvider);
  return ref.read(contentServiceProvider).loadActivity(storyId);
}
