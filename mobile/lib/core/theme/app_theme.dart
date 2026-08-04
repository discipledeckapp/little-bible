import 'package:flutter/material.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
// Aligned with littlebible.org globals.css. Never use a hex literal elsewhere.

class AppColours {
  AppColours._();

  // ── Brand primary ──────────────────────────────────────────────────────────
  static const lumiGold    = Color(0xFFF59E0B);  // wisdom-gold — CTAs, seeds, highlights
  static const lumiGoldLight = Color(0xFFFEF3C7); // wisdom-light — card backgrounds
  static const deepEarth   = Color(0xFF78350F);  // bible-brown — warmth accent

  // ── Step mode colours (aligns with web mode tokens) ───────────────────────
  static const sky          = Color(0xFF60A5FA);  // prayer / discuss / peace
  static const skyLight     = Color(0xFFEFF6FF);
  static const prayerPurple = Color(0xFFA78BFA);  // spiritual depth
  static const prayerLight  = Color(0xFFF5F3FF);
  static const growthGreen  = Color(0xFF34D399);  // completion / encouragement
  static const growthLight  = Color(0xFFECFDF5);
  static const earth        = Color(0xFF16A34A);  // remember / correct — text/icon use
  static const coral        = Color(0xFFFB7185);  // love / warmth / incorrect

  // ── Backgrounds ───────────────────────────────────────────────────────────
  static const cream        = Color(0xFFFFFBF5);  // primary background
  static const warmCream    = Color(0xFFFFF8EC);  // story/verse card backgrounds
  static const parchment    = Color(0xFFF5EDD6);  // illustration / verse emphasis
  static const surface      = Color(0xFFFFFFFF);
  static const darkBg       = Color(0xFF1C1917);
  static const surfaceDark  = Color(0xFF292524);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const textDark     = Color(0xFF1C1917);
  static const textLight    = Color(0xFFF5F5F4);
  // textMuted was #A8A29E (2.45:1 on cream — WCAG fail). Fixed to #57534E (6.5:1).
  static const textMuted    = Color(0xFF57534E);
  static const textSubtle   = Color(0xFF78716C);  // secondary labels only at ≥18sp bold

  // ── Semantic aliases ───────────────────────────────────────────────────────
  static const correct      = earth;     // never colour-only — pair with icon
  static const incorrect    = coral;
}

class AppTextStyles {
  AppTextStyles._();

  // ── Scripture ──────────────────────────────────────────────────────────────
  // LBV adapted verse: Nunito Bold
  static const verseAdapted = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.5,
  );
  // WEB (unadapted) verse: Lora Italic
  static const verseWeb = TextStyle(
    fontFamily: 'Lora',
    fontSize: 20,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    height: 1.6,
  );

  // ── Story narration ────────────────────────────────────────────────────────
  static const storyBody = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.75,
  );

  // ── UI chrome ─────────────────────────────────────────────────────────────
  static const label = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );
  static const heading = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 26,
    fontWeight: FontWeight.w800,
  );
  // Large child-facing card title (story card, featured card)
  static const cardTitle = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Nunito',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColours.lumiGold,
        brightness: Brightness.light,
        surface: AppColours.cream,
        // Pin onSurface so TextField input text and body text are always
        // high-contrast dark, not the amber tint fromSeed would derive.
        onSurface: AppColours.textDark,
        onSurfaceVariant: AppColours.textMuted,
      ),
      scaffoldBackgroundColor: AppColours.cream,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColours.surface,
        hintStyle: AppTextStyles.label.copyWith(color: AppColours.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColours.textMuted.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColours.textMuted.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColours.lumiGold, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColours.surface,
        indicatorColor: AppColours.lumiGold.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColours.lumiGold
                : AppColours.textSubtle),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColours.lumiGold.withValues(alpha: 0.35)
                : Colors.grey.shade300),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Nunito',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColours.lumiGold,
        brightness: Brightness.dark,
        surface: AppColours.darkBg,
        onSurface: AppColours.textLight,
        onSurfaceVariant: AppColours.textSubtle,
      ),
      scaffoldBackgroundColor: AppColours.darkBg,
    );
  }
}
