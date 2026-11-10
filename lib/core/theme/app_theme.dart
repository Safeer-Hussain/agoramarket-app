import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryTeal = Color(0xFF00E5BA);
  static const Color secondaryCoral = Color(0xFFFF6B4A);
  static const Color accentAmber = Color(0xFFFFA800);
  static const Color obsidianDark = Color(0xFF0D1117);
  static const Color slateCardDark = Color(0xFF161B22);
  static const Color slateBorderDark = Color(0xFF30363D);

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: primaryTeal,
      onPrimary: const Color(0xFF00382E),
      primaryContainer: const Color(0xFF005143),
      onPrimaryContainer: const Color(0xFF65F7D8),
      secondary: secondaryCoral,
      onSecondary: const Color(0xFF5F1400),
      secondaryContainer: const Color(0xFF862200),
      onSecondaryContainer: const Color(0xFFFFDBD1),
      tertiary: accentAmber,
      onTertiary: const Color(0xFF452B00),
      tertiaryContainer: const Color(0xFF633F00),
      onTertiaryContainer: const Color(0xFFFFDF9E),
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
      errorContainer: const Color(0xFF93000A),
      onErrorContainer: const Color(0xFFFFDAD6),
      surface: obsidianDark,
      onSurface: const Color(0xFFE6EDF3),
      surfaceContainerLowest: const Color(0xFF080C10),
      surfaceContainerLow: const Color(0xFF11161D),
      surfaceContainer: slateCardDark,
      surfaceContainerHigh: const Color(0xFF1F242C),
      surfaceContainerHighest: const Color(0xFF2B313A),
      onSurfaceVariant: const Color(0xFF8B949E),
      outline: const Color(0xFF6E7681),
      outlineVariant: slateBorderDark,
      shadow: const Color(0xFF000000),
      scrim: const Color(0xFF000000),
      inverseSurface: const Color(0xFFF0F6FC),
      onInverseSurface: const Color(0xFF161B22),
      inversePrimary: const Color(0xFF006B57),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        modalBackgroundColor: colorScheme.surfaceContainer,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: const Color(0xFF006C59),
      onPrimary: const Color(0xFFFFFFFF),
      primaryContainer: const Color(0xFF73F8D8),
      onPrimaryContainer: const Color(0xFF002019),
      secondary: const Color(0xFFA53C1B),
      onSecondary: const Color(0xFFFFFFFF),
      secondaryContainer: const Color(0xFFFFDBD1),
      onSecondaryContainer: const Color(0xFF3B0900),
      tertiary: const Color(0xFF7A5900),
      onTertiary: const Color(0xFFFFFFFF),
      tertiaryContainer: const Color(0xFFFFDF9E),
      onTertiaryContainer: const Color(0xFF261A00),
      error: const Color(0xFFBA1A1A),
      onError: const Color(0xFFFFFFFF),
      errorContainer: const Color(0xFFFFDAD6),
      onErrorContainer: const Color(0xFF410002),
      surface: const Color(0xFFF8FAFC),
      onSurface: const Color(0xFF0F172A),
      surfaceContainerLowest: const Color(0xFFFFFFFF),
      surfaceContainerLow: const Color(0xFFF1F5F9),
      surfaceContainer: const Color(0xFFE2E8F0),
      surfaceContainerHigh: const Color(0xFFCBD5E1),
      surfaceContainerHighest: const Color(0xFF94A3B8),
      onSurfaceVariant: const Color(0xFF475569),
      outline: const Color(0xFF64748B),
      outlineVariant: const Color(0xFFCBD5E1),
      shadow: const Color(0xFF000000),
      scrim: const Color(0xFF000000),
      inverseSurface: const Color(0xFF1E293B),
      onInverseSurface: const Color(0xFFF8FAFC),
      inversePrimary: primaryTeal,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainerLowest,
        modalBackgroundColor: colorScheme.surfaceContainerLowest,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
