import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const black = Color(0xFF050505);
  static const surface = Color(0xEFFFF7D6);
  static const surfaceHigh = Color(0xFFFFEDAE);
  static const gold = Color(0xFFFFD45C);
  static const lightGold = Color(0xFFFFF0B5);
  static const muted = Color(0xFF756A58);
  static const danger = Color(0xFFFF6B81);
  static const sky = Color(0xFFFFD45C);
  static const silver = Color(0xFFFFF0B5);
  static const sapphire = Color(0xFF8A681A);
}

class AppTheme {
  AppTheme._();

  static ThemeData get glitter => _build(
        brightness: Brightness.light,
        background: const Color(0x00FFFFFF),
        surface: const Color(0xEFFFF7D6),
        surfaceHigh: const Color(0xFFFFEDAE),
        appBarColor: const Color(0xF7FFFFFF),
        navigationColor: const Color(0xFAFFFFFF),
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        background: const Color(0x00000000),
        surface: const Color(0xF2181508),
        surfaceHigh: const Color(0xF5241D0A),
        appBarColor: const Color(0xF2050505),
        navigationColor: const Color(0xFA050505),
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceHigh,
    required Color appBarColor,
    required Color navigationColor,
  }) {
    final foreground =
        brightness == Brightness.light ? const Color(0xFF17120A) : Colors.white;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.gold,
      brightness: brightness,
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: scheme.copyWith(
        primary: AppColors.gold,
        secondary: AppColors.silver,
        tertiary: AppColors.sapphire,
        surface: surface,
        surfaceContainerHighest: surfaceHigh,
        onSurface: foreground,
        onPrimary: const Color(0xFF171004),
        error: AppColors.danger,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: appBarColor,
        foregroundColor: foreground,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shadowColor: AppColors.gold.withValues(alpha: .24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0x66FFD45C)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceHigh,
        labelStyle: TextStyle(color: foreground.withValues(alpha: .68)),
        hintStyle: TextStyle(color: foreground.withValues(alpha: .58)),
        floatingLabelStyle: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w800,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: const Color(0xFF171004),
          minimumSize: const Size.fromHeight(52),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navigationColor,
        indicatorColor: AppColors.gold.withValues(alpha: .24),
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceHigh,
        selectedColor: AppColors.gold,
        side: const BorderSide(color: Color(0x66FFD45C)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerColor: const Color(0x55FFD45C),
    );
  }
}
