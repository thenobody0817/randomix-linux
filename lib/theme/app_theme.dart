/// Material 3 themes for the desktop port.
library;

import 'package:flutter/material.dart';

import 'accent_colors.dart';

class AppTheme {
  const AppTheme._();

  static const Color _fallbackSeed = Color(0xFF4285F4);

  static ThemeData build({
    required Brightness brightness,
    required Accent accent,
    required bool amoled,
    Color? systemSeed,
  }) {
    final seed = accent.seed ?? systemSeed ?? _fallbackSeed;
    var scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);

    if (amoled && brightness == Brightness.dark) {
      scheme = scheme.copyWith(
        surface: Colors.black,
        surfaceContainerLowest: Colors.black,
        surfaceContainerLow: const Color(0xFF0A0A0A),
        surfaceContainer: const Color(0xFF121212),
        surfaceContainerHigh: const Color(0xFF1A1A1A),
        surfaceContainerHighest: const Color(0xFF222222),
        onSurface: const Color(0xFFEDEDED),
      );
    }

    return ThemeData(
      colorScheme: scheme,
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {TargetPlatform.linux: FadeForwardsPageTransitionsBuilder()},
      ),
    );
  }
}
