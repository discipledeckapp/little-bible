import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_bible/core/models/story_model.dart';
import 'package:little_bible/core/theme/app_theme.dart';
import 'package:little_bible/features/story/widgets/highlight_text.dart';

// The screen itself needs Drift, TTS and audioplayers, so these goldens cover
// the presentation layer: the verse body as each age band sees it, with and
// without an active word highlight.
//
// Regenerate with:
//   flutter test --update-goldens test/widget/bible_verse_screen_golden_test.dart

const _verse = StoryVerse(
  ref: 'Genesis 1:1',
  kjv: 'In the beginning God created the heaven and the earth.',
  littleBible:
      'Before anything existed, God was already there. And He made everything!',
);

void main() {
  Widget harness({
    required bool isPreReader,
    int? highlightStart,
    int? highlightEnd,
  }) {
    final align = isPreReader ? TextAlign.center : TextAlign.start;
    return MaterialApp(
      theme: AppTheme.light(),
      home: MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Scaffold(
          backgroundColor: AppColours.warmCream,
          body: Center(
            child: RepaintBoundary(
              key: const ValueKey('verse'),
              child: SizedBox(
                width: 411,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: isPreReader
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: [
                      Text(_verse.ref,
                          style: AppTextStyles.label.copyWith(
                            color: AppColours.textMuted,
                            fontSize: 12,
                          )),
                      const SizedBox(height: 20),
                      HighlightText(
                        text: _verse.littleBible,
                        highlightStart: highlightStart,
                        highlightEnd: highlightEnd,
                        textAlign: align,
                        style: TextStyle(
                          fontFamily: 'Lora',
                          fontSize: isPreReader ? 25 : 22,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF3B2A1A),
                          height: 1.65,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('early band — centred, larger, no highlight', (tester) async {
    await tester.pumpWidget(harness(isPreReader: true));
    await tester.pump();
    await expectLater(find.byKey(const ValueKey('verse')),
        matchesGoldenFile('goldens/verse_early.png'));
  });

  testWidgets('reading band — left aligned, mid-narration highlight',
      (tester) async {
    // "God" — the word a highlight should land on cleanly.
    await tester.pumpWidget(
      harness(isPreReader: false, highlightStart: 25, highlightEnd: 28),
    );
    await tester.pump();
    await expectLater(find.byKey(const ValueKey('verse')),
        matchesGoldenFile('goldens/verse_reading_highlighted.png'));
  });
}
