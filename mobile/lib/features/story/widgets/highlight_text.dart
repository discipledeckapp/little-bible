import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Verse text with a word-by-word highlight that follows narration.
///
/// Mapping spoken sound onto printed words is how an emerging reader learns to
/// read, and it gives a pre-reader something to watch while listening — which is
/// why every screen that reads Scripture aloud should use this rather than a
/// plain `Text`.
///
/// `highlightStart`/`highlightEnd` are character offsets into `text`, as
/// supplied by `TtsService.speakWithHighlight`. When either is null the text
/// renders unhighlighted, so this is safe to use with pre-recorded audio that
/// cannot report word boundaries.
class HighlightText extends StatelessWidget {
  const HighlightText({
    super.key,
    required this.text,
    this.highlightStart,
    this.highlightEnd,
    this.style,
    this.textAlign = TextAlign.center,
  });

  final String text;
  final int? highlightStart;
  final int? highlightEnd;
  final TextStyle? style;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ??
        AppTextStyles.verseAdapted.copyWith(
          color: AppColours.textDark,
          fontSize: 22,
          height: 1.6,
        );

    if (highlightStart == null || highlightEnd == null) {
      return Text(text, style: baseStyle, textAlign: textAlign);
    }

    final start = highlightStart!.clamp(0, text.length);
    final end = highlightEnd!.clamp(start, text.length);

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          if (start > 0) TextSpan(text: text.substring(0, start)),
          TextSpan(
            text: text.substring(start, end),
            style: TextStyle(
              backgroundColor: AppColours.lumiGold.withValues(alpha: 0.3),
              color: AppColours.textDark,
            ),
          ),
          if (end < text.length) TextSpan(text: text.substring(end)),
        ],
      ),
      textAlign: textAlign,
    );
  }
}
