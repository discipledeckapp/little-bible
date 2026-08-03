import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/story_model.dart';
import '../../../core/models/activity_model.dart';
import '../../../core/services/content_service.dart';

part 'story_provider.g.dart';

@riverpod
Future<StoryModel> story(Ref ref, String storyId) =>
    ref.read(contentServiceProvider).loadStory(storyId);

@riverpod
Future<List<StoryModel>> allStories(Ref ref) =>
    ref.read(contentServiceProvider).loadAllStories();

@riverpod
Future<ActivityModel?> storyActivity(Ref ref, String storyId) =>
    ref.read(contentServiceProvider).loadActivity(storyId);
