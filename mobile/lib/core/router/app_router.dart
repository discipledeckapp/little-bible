import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/story/screens/story_player_screen.dart';
import '../../features/story/screens/key_verse_screen.dart';
import '../../features/story/screens/family_moment_screen.dart';
import '../../features/story/screens/games_screen.dart';
import '../../features/story/screens/bible_verse_screen.dart';
import '../../features/story/screens/coloring_screen.dart';
import '../../features/bible/screens/bible_nav_screen.dart';
import '../../features/bible/screens/book_picker_screen.dart';
import '../../features/bible/screens/chapter_picker_screen.dart';
import '../../features/bible/screens/verse_reader_screen.dart';
import '../../features/parent_hub/screens/parent_hub_screen.dart';
import '../../features/unlock/screens/unlock_screen.dart';
import '../../features/verse_practice/screens/verse_practice_screen.dart';
import '../providers/profile_provider.dart';

part 'app_router.g.dart';

/// Shared navigator key so non-widget code (e.g. notification handlers) can
/// push routes without needing a BuildContext.
final appNavigatorKey = GlobalKey<NavigatorState>();

// ─── Route names (use these constants, never raw strings) ────────────────────
class AppRoutes {
  static const splash       = '/splash';
  static const onboarding   = '/onboarding';
  static const home         = '/';
  static const story        = '/story/:storyId';
  static const bibleNav     = '/bible';
  static const bibleMyVerses = '/bible/my-verses';
  static const bibleBook    = '/bible/:book';
  static const bibleChapter = '/bible/:book/:chapter';
  static const bibleVerse   = '/bible/:book/:chapter/:verse';
  static const parentHub    = '/parent-hub';
  static const unlock       = '/unlock';
}

@riverpod
GoRouter appRouter(Ref ref) {
  final hasProfile = ref.watch(hasActiveProfileProvider);

  return GoRouter(
    navigatorKey: appNavigatorKey,
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final isSplash = loc == AppRoutes.splash;
      final isOnboarding = loc == AppRoutes.onboarding;
      // Splash handles its own navigation; don't redirect away from it.
      if (isSplash) return null;
      if (!hasProfile && !isOnboarding) return AppRoutes.onboarding;
      if (hasProfile && isOnboarding)  return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'story/:storyId',
            builder: (context, state) => StoryPlayerScreen(
              storyId: state.pathParameters['storyId']!,
            ),
            routes: [
              GoRoute(
                path: 'verse',
                builder: (context, state) => KeyVerseScreen(
                  storyId: state.pathParameters['storyId']!,
                ),
              ),
              GoRoute(
                path: 'bible',
                builder: (context, state) => BibleVerseScreen(
                  storyId: state.pathParameters['storyId']!,
                ),
              ),
              GoRoute(
                path: 'games',
                builder: (context, state) => GamesScreen(
                  storyId: state.pathParameters['storyId']!,
                ),
              ),
              GoRoute(
                path: 'color',
                builder: (context, state) => ColoringScreen(
                  storyId: state.pathParameters['storyId']!,
                ),
              ),
              GoRoute(
                path: 'family',
                builder: (context, state) => FamilyMomentScreen(
                  storyId: state.pathParameters['storyId']!,
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.bibleNav,
        builder: (context, _) => const BookPickerScreen(),
        routes: [
          GoRoute(
            path: 'my-verses',
            builder: (context, _) => const BibleNavScreen(),
          ),
          GoRoute(
            path: ':book',
            builder: (context, state) => ChapterPickerScreen(
              book: state.pathParameters['book']!,
            ),
            routes: [
              GoRoute(
                path: ':chapter',
                builder: (context, state) => VerseReaderScreen(
                  book:       state.pathParameters['book']!,
                  chapter:    int.parse(state.pathParameters['chapter']!),
                  startVerse: 1,
                ),
                routes: [
                  GoRoute(
                    path: ':verse',
                    builder: (context, state) => VerseReaderScreen(
                      book:       state.pathParameters['book']!,
                      chapter:    int.parse(state.pathParameters['chapter']!),
                      startVerse: int.parse(state.pathParameters['verse']!),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/practice/:storyId',
        builder: (context, state) => VersePracticeScreen(
          storyId: state.pathParameters['storyId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.parentHub,
        builder: (context, state) => const ParentHubScreen(),
      ),
      GoRoute(
        path: AppRoutes.unlock,
        builder: (context, state) => const UnlockScreen(),
      ),
    ],
  );
}
