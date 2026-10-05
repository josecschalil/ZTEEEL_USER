import 'package:flutter/material.dart';

/// Customer app colors. The Deals page's #EE5B2B is the shared primary.
/// Dark surfaces, status colors, and gradient stops remain available here.

abstract final class AppColors {
  // ── Backgrounds ────────────────────────────────────────────────────
  static const Color bg = Color(0xFFFAFAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceRaised = Color(0xFFF3F4F6);

  // Was a warm beige. Now a very subtle coral-tinted surface.
  static const Color surfaceRaisedWarm = Color(0xFFFFF7F5);

  static const Color surfaceElevated = Color(0xFFFCE9E6);

  // ── Brand / Accent — Deals orange ───────────────────────────────────
  static const Color primary = Color(0xFFEE5B2B);
  static const Color primarySoft = Color(0xFFFFF1EB);
  static const Color primaryDeep = Color(0xFFC2410C);

  static const Color orange = primary;
  static const Color orangeLight = Color(0xFFF57A6E);
  static const Color coralGradientStop = Color(0xFFEF5A4C);
  static const Color apricotTint = Color(0xFFFDECE4);

  static const Color orangeDim = Color(0x1AEE5B2B);
  static const Color orangeBorder = Color(0x40EE5B2B);
  static const Color orangeTint = Color(0xFFFDECEA);

  /// Warm orange used in the splash/onboarding animation
  static const Color orangeWarm = Color(0xFFE87722);

  // ── Gold (premium / featured badges) ────────────────────────────────
  static const Color gold = Color(0xFFC4922E);
  static const Color yellow = Color(0xFFFBBF24);
  static const Color amber = Color(0xFFF59E0B);
  static const Color purple = Color(0xFF8B5CF6);

  // ── Semantic: Success / Open ────────────────────────────────────────
  static const Color green = Color(0xFF10B981);
  static const Color success = Color(0xFF16A34A);
  static const Color supportGreen = Color(0xFF1D9E6B);
  static const Color vegGreen = Color(0xFF22C55E);
  static const Color nonVegRed = Color(0xFFEF4444);
  static const Color greenDim = Color(0x1A1D9E6B);
  static const Color greenBorder = Color(0x401D9E6B);

  // ── Semantic: Danger / Error ────────────────────────────────────────
  static const Color red = Color(0xFFD32F3F);
  static const Color warning = amber;

  // ── Text — for use on light surfaces ────────────────────────────────

  /// Headings, primary body text.
  static const Color textPrimary = Color(0xFF1D1E20);

  /// Supporting text — labels, descriptions, secondary lines.
  static const Color textSecondary = Color(0xFF4B5563);

  /// Low-emphasis text — placeholders, timestamps, hints.
  static const Color textMuted = Color(0xFF8A8A9A);

  // Was brown-tinted. Now neutral for dark-surface secondary text.
  static const Color textMutedDark = Color(0xFFB9BBC2);

  // ── Text — dark / saturated backgrounds ─────────────────────────────

  static const Color textOnAccent = Color(0xFFFFFFFF);
  static const Color textInverse = Color(0xFFFFFFFF);

  /// @deprecated Kept only so old references still compile while you
  /// migrate call sites.
  static const Color textWhite = textInverse;

  // ── Borders / Dividers ─────────────────────────────────────────────
  static const Color border = Color(0xFFF0F0F3);
  static const Color borderAccent = primary;

  // ── Navigation Bar ─────────────────────────────────────────────────
  static const Color navBg = Color(0xFFFFFFFF);

  // ── Misc ───────────────────────────────────────────────────────────
  static const Color separator = Color(0x0F000000);
  static const Color transparent = Colors.transparent;
  static const Color black = Colors.black;

  /// Deep dark background used in the splash screen animation.
  /// Was dark brown; now neutral charcoal.
  static const Color bgSplash = Color(0xFF191A1D);

  /// Existing role retained.
  /// Was dark brown; now pale coral.
  static const Color surfaceWarm = Color(0xFFFFE9E5);

  // ── Earlier warm/slate neutrals ─────────────────────────────────────
  //
  // Names retained so existing call sites continue to work.
  // Values now follow the coral / neutral system.

  static const Color warmBackground = Color(0xFFFFF8F6);
  static const Color warmBorder = Color(0xFFFFDDD6);

  static const Color warmTextPrimary = Color(0xFF1D1E20);
  static const Color warmTextSecondary = Color(0xFF5B5E66);
  static const Color warmTextMuted = Color(0xFF989AA2);

  static const Color supportTextPrimary = Color(0xFF1D1E20);
  static const Color supportTextSecondary = Color(0xFF585B63);
  static const Color supportTextMuted = Color(0xFF90929A);

  // ── Shared dark surfaces ────────────────────────────────────────────
  //
  // Previously brown-tinted.
  // Now neutral charcoal/slate to avoid introducing another hue family.

  static const Color bgDark = Color(0xFF191A1D);
  static const Color cardDark = Color(0xFF232428);
  static const Color borderDark = Color(0xFF37383E);

  static const Color checkoutBgDark = Color(0xFF1D1E21);
  static const Color checkoutNavDark = Color(0xFF17181B);

  static const Color redeemSurfaceDark = Color(0xFF292A2F);
  static const Color redeemTimerDark = Color(0xFF36373D);

  // ── Role aliases used across older screen layouts ──────────────────
  static const Color bgLight = bg;
  static const Color backgroundLight = bg;
  static const Color backgroundDark = bgDark;

  static const Color cardLight = surface;

  static const Color borderLight = border;

  static const Color textMutedLight = textMuted;
  static const Color mutedTextLight = textMuted;
  static const Color mutedTextDark = textMutedDark;
  static const Color mutedText = textSecondary;

  static const Color white = Colors.white;
  static const Color nearWhite = Color(0xFFFCFCFC);

  // Was slightly warm beige. Now neutral.
  static const Color chipLight = Color(0xFFF3F4F6);

  static const Color surfaceDark = cardDark;
  static const Color surfaceDarkAlt = cardDark;

  static const Color navBorderDark = borderDark;

  static const Color cardFill = cardDark;
  static const Color cardBorder = borderDark;

  static const Color bgDeep = bgDark;

  static const Color textDescription = textMutedDark;

  /// Neutral icon / placeholder grey.
  static const Color iconGrey = Color(0xFF9A9CA3);

  // ── Flutter material shades ─────────────────────────────────────────
  static const MaterialColor materialGrey = Colors.grey;
  static const MaterialColor materialGreen = Colors.green;
  static const MaterialColor materialRed = Colors.red;
  static const MaterialColor materialAmber = Colors.amber;

  static const Color materialRedAccent = Colors.redAccent;
  static const Color materialAmberAccent = Colors.amberAccent;

  static const Color white10 = Colors.white10;
  static const Color white24 = Colors.white24;
  static const Color white30 = Colors.white30;
  static const Color white54 = Colors.white54;
  static const Color white60 = Colors.white60;
  static const Color white70 = Colors.white70;

  static const Color black12 = Colors.black12;
  static const Color black26 = Colors.black26;
  static const Color black87 = Colors.black87;

  // ── Existing illustration, badge, and gradient stops ────────────────
  //
  // Definition names retained exactly.
  // Brown-coded tones have been changed to neutral equivalents.

  static const Color tone18000000 = Color(0x18000000);

  static const Color tone1AC4922E = Color(0x1AC4922E);
  static const Color tone40C4922E = Color(0x40C4922E);

  static const Color toneD9FAFAFB = Color(0xD9FAFAFB);
  static const Color toneF7FFFFFF = Color(0xF7FFFFFF);

  static const Color toneFF0284C7 = Color(0xFF0284C7);
  static const Color toneFF059669 = Color(0xFF059669);
  static const Color toneFF0D9488 = Color(0xFF0D9488);

  static const Color toneFF0F172A = Color(0xFF0F172A);
  static const Color toneFF1E293B = Color(0xFF1E293B);

  static const Color toneFF2D2D2D = Color(0xFF2D2D2D);
  static const Color toneFF2F2F2F = Color(0xFF2F2F2F);

  // Was #35261F brown
  static const Color toneFF35261F = Color(0xFF34353A);

  static const Color toneFF374151 = Color(0xFF374151);

  // Was #3A2820 brown
  static const Color toneFF3A2820 = Color(0xFF3A3B41);

  // Was #3B2921 brown
  static const Color toneFF3B2921 = Color(0xFF3D3E44);

  static const Color toneFF3B82F6 = Color(0xFF3B82F6);

  // Was #453026 brown
  static const Color toneFF453026 = Color(0xFF47484F);

  static const Color toneFF475569 = Color(0xFF475569);
  static const Color toneFF4B5563 = Color(0xFF4B5563);
  static const Color toneFF4F46E5 = Color(0xFF4F46E5);

  static const Color toneFF64748B = Color(0xFF64748B);
  static const Color toneFF6B7280 = Color(0xFF6B7280);

  static const Color toneFF8E8E93 = Color(0xFF8E8E93);

  static const Color toneFF9333EA = Color(0xFF9333EA);
  static const Color toneFF94A3B8 = Color(0xFF94A3B8);
  static const Color toneFF9CA3AF = Color(0xFF9CA3AF);

  static const Color toneFFA855F7 = Color(0xFFA855F7);

  static const Color toneFFB91C1C = Color(0xFFB91C1C);
  static const Color toneFFC026D3 = Color(0xFFC026D3);

  static const Color toneFFD97706 = Color(0xFFD97706);
  static const Color toneFFDC2626 = Color(0xFFDC2626);

  static const Color toneFFE11D48 = Color(0xFFE11D48);

  static const Color toneFFE2E8F0 = Color(0xFFE2E8F0);
  static const Color toneFFE5E7EB = Color(0xFFE5E7EB);

  static const Color toneFFEA580C = Color(0xFFEA580C);
  static const Color toneFFEC4899 = Color(0xFFEC4899);

  // Slight beige retained as a light neutral; not visually brown.
  static const Color toneFFEDE7E2 = Color(0xFFF1EEEE);

  static const Color toneFFEEEEEE = Color(0xFFEEEEEE);

  static const Color toneFFF1F5F9 = Color(0xFFF1F5F9);
  static const Color toneFFF43F5E = Color(0xFFF43F5E);

  static const Color toneFFF9FAFB = Color(0xFFF9FAFB);
  static const Color toneFFFAFAFB = Color(0xFFFAFAFB);

  static const Color toneFFFFC107 = Color(0xFFFFC107);

  // Existing light orange/amber backgrounds retained.
  static const Color toneFFFFF7ED = Color(0xFFFFF7ED);
  static const Color toneFFFFFBEB = Color(0xFFFFFBEB);
}
