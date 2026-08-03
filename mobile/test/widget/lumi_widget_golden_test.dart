import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_bible/core/theme/app_theme.dart';
import 'package:little_bible/features/lumi/widgets/lumi_widget.dart';

// Lumi's geometry is hand-tuned to match the app icon vector
// (assets/brand/lumi-app-icon.svg). These goldens are the guard: if someone
// nudges a coordinate in _LumiFacePainter, the diff shows up here.
//
// Regenerate with:  flutter test --update-goldens test/widget/lumi_widget_golden_test.dart

void main() {
  Widget harness(LumiState state) {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light(),
        home: MediaQuery(
          // Static render — flutter_animate's repeating idle bob would
          // otherwise never settle.
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            backgroundColor: AppColours.cream,
            body: Center(
              child: RepaintBoundary(
                key: const ValueKey('lumi-golden'),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: LumiWidget(state: state, size: 240),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  for (final state in LumiState.values) {
    testWidgets('Lumi renders — ${state.name}', (tester) async {
      await tester.pumpWidget(harness(state));
      await tester.pump();

      await expectLater(
        find.byKey(const ValueKey('lumi-golden')),
        matchesGoldenFile('goldens/lumi_${state.name}.png'),
      );
    });
  }
}
