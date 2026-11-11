import 'package:flutter/material.dart';

import 'tokens.g.dart';

/// A Material [ThemeData] built from the Albatross tokens, so plain Material
/// widgets (Scaffold, AppBar, Divider, SnackBar text) start from the DS look.
/// The Ads* widgets do not depend on it; they read the tokens directly.
///
/// ```dart
/// MaterialApp(theme: AdsTheme.light(), home: const HomePage())
/// ```
abstract final class AdsTheme {
  /// Font family name for a package font.
  static const String fontFamily = 'packages/albatross_ds/Manrope';

  static ThemeData light() {
    const ColorScheme scheme = ColorScheme.light(
      primary: AdsColors.purple500,
      onPrimary: AdsColors.light100,
      primaryContainer: AdsColors.purple50,
      onPrimaryContainer: AdsColors.purple600,
      secondary: AdsColors.teal500,
      onSecondary: AdsColors.light100,
      error: AdsColors.red500,
      onError: AdsColors.light100,
      surface: AdsColors.light100,
      onSurface: AdsColors.dark500,
      onSurfaceVariant: AdsColors.dark300,
      outline: AdsColors.light500,
      outlineVariant: AdsColors.light400,
    );
    final TextTheme text = const TextTheme(
      displayLarge: AdsType.h1,
      displayMedium: AdsType.h2,
      displaySmall: AdsType.h3,
      headlineLarge: AdsType.h3,
      headlineMedium: AdsType.h4,
      headlineSmall: AdsType.h5,
      titleLarge: AdsType.s1s,
      titleMedium: AdsType.s2s,
      titleSmall: AdsType.s3s,
      bodyLarge: AdsType.b1,
      bodyMedium: AdsType.b2,
      bodySmall: AdsType.b3,
      labelLarge: AdsType.ctaL,
      labelMedium: AdsType.lblL,
      labelSmall: AdsType.lblS,
    ).apply(bodyColor: AdsColors.dark500, displayColor: AdsColors.dark500);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
      textTheme: text,
      scaffoldBackgroundColor: AdsColors.light100,
      dividerColor: AdsColors.light500,
      dividerTheme: const DividerThemeData(color: AdsColors.light500, thickness: 1, space: 1),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AdsColors.purple500,
        selectionColor: AdsColors.purple100,
        selectionHandleColor: AdsColors.purple500,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AdsColors.light100,
        foregroundColor: AdsColors.dark500,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AdsType.h5.copyWith(color: AdsColors.dark500),
      ),
    );
  }
}
