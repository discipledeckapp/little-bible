import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_bible/features/story/widgets/scene_painter.dart';

// Scene illustration goldens — § 7 of the Animation Standard.
//
// Every story × both extreme aspect ratios × three t values = 90 images.
// Regenerate:  flutter test --update-goldens test/widget/scene_painter_golden_test.dart
//
// MANDATORY: after generating, open every PNG in goldens/ and inspect visually.
// Tests passing is NOT verification — the images must be looked at (§ 7).
//
// Aspects:
//   411 × 240  — story player header (widest real box)
//   136 × 108  — home story card (smallest real box)

void main() {
  const storyIds = [
    'god-made-everything',
    'god-made-me',
    'the-first-family',
    'the-very-sad-choice',
    'god-promises-a-rescuer',
    'two-brothers',
    'noahs-big-boat',
    'noahs-rainbow-promise',
    'the-tall-tower',
    'god-calls-abraham',
    'stars-in-the-sky',
    'the-promised-son',
    'god-provides-a-lamb',
    'jacob-learns-grace',
    'joseph-and-his-brothers',
    'joseph-forgives-his-family',
    'baby-moses-is-kept-safe',
    'god-calls-from-the-fire',
    'let-my-people-go',
    'the-passover-lamb',
    'a-way-through-the-sea',
    'bread-in-the-wilderness',
    'gods-good-commands',
    'god-lives-with-his-people',
    'twelve-spies',
    'joshua-and-the-walls',
    'deborah-leads-gods-people',
    'gideons-tiny-army',
    'ruth-finds-a-home',
    'samuel-listens-to-god',
    'saul-the-king',
    'david-and-the-giant',
    'davids-sin-and-gods-mercy',
    'gods-forever-king-promise',
    'solomon-asks-for-wisdom',
    'elijah-and-the-only-true-god',
    'the-prophets-promise-new-hearts',
    'an-angel-visits-mary',
    'visitors-worship-the-king',
    'jesus-grows-and-obeys',
    'jesus-is-baptised',
    'jesus-says-no-to-tempter',
    'jesus-calls-his-helpers',
    'birth-of-jesus',
    'jesus-loves-children',
    'david-the-shepherd-boy',
    'daniel-and-the-lions',
    'jonah-and-the-big-fish',
    'the-lost-sheep',
    'the-lost-son',
    'the-good-shepherd',
    'how-to-pray',
    'the-good-neighbour',
    'jesus-saves',
    'jesus-calms-the-storm',
    'jesus-heals-and-forgives',
    'jesus-feeds-the-crowd',
    'jesus-raises-lazarus',
    'the-king-rides-in',
    'servant-king-washes-feet',
    'the-last-supper',
    'jesus-prays-in-garden',
    'jesus-dies-for-sinners',
    'jesus-is-alive',
    'jesus-returns-to-his-father',
    'the-holy-spirit-comes',
    'a-new-sharing-family',
    'stephen-sees-jesus',
    'saul-meets-the-risen-jesus',
    'peter-welcomes-cornelius',
    'paul-and-silas-in-prison',
    'the-spirit-grows-good-fruit',
    'gods-armour-for-hard-days',
    'when-anger-knocks',
    'when-i-feel-alone',
    'when-life-feels-unfair',
    'when-someone-we-love-dies',
    'jesus-will-come-again',
    'the-king-judges',
    'god-makes-everything-new',
  ];

  const aspects = [
    (411.0, 240.0, 'wide'),  // story player header
    (136.0, 108.0, 'card'),  // home card
  ];

  const tValues = [0.0, 0.5, 1.0];

  Widget harness(String storyId, double w, double h, double t) {
    return MaterialApp(
      home: MediaQuery(
        // Disable animations so test output is deterministic.
        data: const MediaQueryData(disableAnimations: true),
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: RepaintBoundary(
              key: ValueKey('$storyId-$w-$t'),
              child: SizedBox(
                width: w,
                height: h,
                child: CustomPaint(
                  painter: sceneFor(storyId, 0, t),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  for (final storyId in storyIds) {
    for (final (w, h, label) in aspects) {
      for (final t in tValues) {
        final tLabel = t.toStringAsFixed(1).replaceAll('.', '_');
        testWidgets('$storyId — $label — t=$t', (tester) async {
          tester.view.physicalSize = Size(w * 3, h * 3); // 3× for retina clarity
          tester.view.devicePixelRatio = 3.0;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(harness(storyId, w, h, t));
          await tester.pump();

          await expectLater(
            find.byKey(ValueKey('$storyId-$w-$t')),
            matchesGoldenFile('goldens/scene_${storyId}_${label}_t$tLabel.png'),
          );
        });
      }
    }
  }

  // Fallback painter — covers the registry-absent case
  for (final (w, h, label) in aspects) {
    testWidgets('fallback — $label — t=1.0', (tester) async {
      tester.view.physicalSize = Size(w * 3, h * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(harness('__nonexistent__', w, h, 1.0));
      await tester.pump();

      await expectLater(
        find.byKey(ValueKey('__nonexistent__-$w-1.0')),
        matchesGoldenFile('goldens/scene_fallback_${label}_t1_0.png'),
      );
    });
  }
}
