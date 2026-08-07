import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_bible/core/theme/app_theme.dart';
import 'package:little_bible/features/unlock/screens/unlock_screen.dart';

/// Generates the App Store Connect in-app-purchase review screenshot.
///
/// Apple requires an image showing where the purchase appears in the app,
/// minimum 640×920. This renders the real [UnlockContent] — the same widget the
/// shipping paywall builds — so the screenshot cannot drift from the app.
///
/// Regenerate after changing the paywall or the price:
///
///   flutter test test/store/iap_review_screenshot_test.dart
///
/// Output: mobile/store/iap_review_screenshot.png
void main() {
  // Shown on the purchase button. Match whatever you set in App Store Connect —
  // StoreKit supplies this at runtime, so it is hard-coded only for the image.
  const displayPrice = r'$4.99';

  // iPhone 15 Pro logical size; captured at 3× for 1179×2556px.
  const logicalSize = Size(393, 852);
  const captureScale = 3.0;
  const outputPath = 'store/iap_review_screenshot.png';

  testWidgets('generates the IAP review screenshot', (tester) async {
    await _loadRealFonts();

    tester.view
      ..physicalSize = Size(logicalSize.width, logicalSize.height)
      ..devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: MediaQuery(
          // Static render — nothing captured mid-animation.
          data: const MediaQueryData(disableAnimations: true),
          child: RepaintBoundary(
            key: const ValueKey('iap-shot'),
            child: UnlockContent(
              price: displayPrice,
              // Non-null so the button renders in its normal enabled state
              // rather than greyed out.
              onClose: () {},
              onPurchase: () {},
              onRestore: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const ValueKey('iap-shot')),
    );

    // toImage and PNG encoding need real async, which pump() does not provide.
    late final ByteData? png;
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: captureScale);
      png = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
    });

    expect(png, isNotNull, reason: 'failed to encode the screenshot');

    final file = File(outputPath)..createSync(recursive: true);
    file.writeAsBytesSync(png!.buffer.asUint8List());

    final decoded = await tester.runAsync(
      () => decodeImageFromList(file.readAsBytesSync()),
    );
    expect(decoded!.width, greaterThanOrEqualTo(640),
        reason: 'App Store Connect requires at least 640px wide');
    expect(decoded.height, greaterThanOrEqualTo(920),
        reason: 'App Store Connect requires at least 920px tall');

    // ignore: avoid_print
    print('Wrote $outputPath (${decoded.width}×${decoded.height})');
  });
}

/// Golden renders show text and icons as filled boxes unless real fonts are
/// registered. A store screenshot must show actual words and glyphs.
Future<void> _loadRealFonts() async {
  // Use FLUTTER_ROOT, which `flutter test` sets. Do NOT derive this from
  // Platform.resolvedExecutable: under `flutter test` that is flutter_tester
  // (in bin/cache/artifacts/engine/<platform>/), not the Dart SDK binary, so
  // walking up parents lands in the wrong directory.
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot == null) {
    fail('FLUTTER_ROOT is not set — run this through `flutter test`.');
  }

  final families = <String, String>{
    'Nunito': 'assets/fonts/Nunito[wght].ttf',
    'Lora': 'assets/fonts/Lora[wght].ttf',
    'MaterialIcons':
        '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  };

  for (final entry in families.entries) {
    final file = File(entry.value);
    // Fail rather than skip: a silently missing font renders every glyph as an
    // empty box, which is exactly how a broken screenshot shipped once already.
    if (!file.existsSync()) {
      fail('Missing font for "${entry.key}": ${entry.value}');
    }
    final loader = FontLoader(entry.key)
      ..addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
    await loader.load();
  }
}
