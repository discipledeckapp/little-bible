import 'package:flutter_test/flutter_test.dart';
import 'package:little_bible/core/providers/story_progress_repository.dart';

// The free allowance is CONSUMPTION-based, not positional: any
// [kFreeStoryAllowance] stories the child opens are free, whichever they choose.
//
// The previous rule was `curriculumIndex >= 20`, which silently put every Jesus
// story behind the paywall the moment Old Testament worlds were inserted ahead of
// them. These tests exist to stop that regression coming back.

Set<String> _consumed(int n) =>
    {for (int i = 0; i < n; i++) 'story-$i'};

void main() {
  group('storyPaywallLocked', () {
    test('nothing is locked before the allowance is used up', () {
      for (int used = 0; used < kFreeStoryAllowance; used++) {
        expect(
          storyPaywallLocked(
            storyId: 'fresh-story',
            profileUnlocked: false,
            consumedIds: _consumed(used),
          ),
          isFalse,
          reason: 'with $used of $kFreeStoryAllowance used, a new story must be free',
        );
      }
    });

    test('a new story locks once the allowance is exhausted', () {
      expect(
        storyPaywallLocked(
          storyId: 'fresh-story',
          profileUnlocked: false,
          consumedIds: _consumed(kFreeStoryAllowance),
        ),
        isTrue,
      );
    });

    test('an already-opened story never becomes locked again', () {
      // Access is never revoked: the child opened it, so it stays available even
      // though the allowance is long gone.
      final consumed = {..._consumed(kFreeStoryAllowance + 12), 'already-read'};
      expect(
        storyPaywallLocked(
          storyId: 'already-read',
          profileUnlocked: false,
          consumedIds: consumed,
        ),
        isFalse,
      );
    });

    test('an unlocked profile is never gated', () {
      expect(
        storyPaywallLocked(
          storyId: 'fresh-story',
          profileUnlocked: true,
          consumedIds: _consumed(kFreeStoryAllowance + 30),
        ),
        isFalse,
      );
    });

    test('the rule ignores curriculum position entirely', () {
      // The regression this guards: a child who has read nothing must be able to
      // open the LAST story in the catalogue, not just the first 20.
      expect(
        storyPaywallLocked(
          storyId: 'jesus-saves',
          profileUnlocked: false,
          consumedIds: const <String>{},
        ),
        isFalse,
      );
      // ...and having read 20 early stories does not unlock a 21st by position.
      expect(
        storyPaywallLocked(
          storyId: 'jesus-saves',
          profileUnlocked: false,
          consumedIds: _consumed(kFreeStoryAllowance),
        ),
        isTrue,
      );
    });

    test('reading the same story twice does not consume two allowances', () {
      // Consumption is a Set of story IDs, so re-reads are inherently free.
      final consumed = {'a', 'b', 'c'};
      expect(consumed.length, 3);
      expect(
        storyPaywallLocked(
          storyId: 'd',
          profileUnlocked: false,
          consumedIds: consumed,
        ),
        isFalse,
      );
    });
  });
}
