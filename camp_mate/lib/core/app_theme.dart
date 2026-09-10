import 'package:flutter/material.dart';

class AppColors {
  static const forest = Color(0xFF12372A);
  static const pine = Color(0xFF1D5B45);
  static const moss = Color(0xFF77A677);
  static const orange = Color(0xFFF59E42);
  static const cream = Color(0xFFF5F1E8);
  static const ink = Color(0xFF13211B);
}

ThemeData campTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.pine,
    brightness: brightness,
    primary: dark ? const Color(0xFF8CC9A7) : AppColors.pine,
    secondary: AppColors.orange,
    surface: dark ? const Color(0xFF17221D) : const Color(0xFFFFFBF4),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor:
        dark ? const Color(0xFF0D1713) : AppColors.cream,
    cardTheme: CardThemeData(
      elevation: 0,
      color: dark ? const Color(0xFF17221D) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? const Color(0xFF1F2D27) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: dark ? Colors.white10 : AppColors.pine.withValues(alpha: .12),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      indicatorColor: scheme.primaryContainer,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    ),
    textTheme: ThemeData(brightness: brightness).textTheme.copyWith(
          headlineLarge: const TextStyle(fontWeight: FontWeight.w800),
          headlineMedium: const TextStyle(fontWeight: FontWeight.w800),
          titleLarge: const TextStyle(fontWeight: FontWeight.w800),
          titleMedium: const TextStyle(fontWeight: FontWeight.w700),
        ),
  );
}
