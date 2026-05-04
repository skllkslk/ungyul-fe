import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF0A0A0F);
  static const card = Color(0xFF13131A);
  static const primary = Color(0xFF8B5CF6);
  static const primaryLight = Color(0xFFAF87FA);
  static const accent = Color(0xFF06B6D4);
  static const foreground = Color(0xFFF8F8FC);
  static const mutedForeground = Color(0xFF9494A8);
  static const border = Color(0xFF2A2A38);
  static const secondary = Color(0xFF1E1E2A);
  static const chart1 = Color(0xFFF59E0B);
  static const chart2 = Color(0xFF10B981);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          surface: AppColors.background,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          onPrimary: Colors.white,
          onSurface: AppColors.foreground,
        ),
        cardTheme: const CardThemeData(
          color: AppColors.card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24)),
            side: BorderSide(color: AppColors.border),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold, fontSize: 22),
          titleMedium: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.w600, fontSize: 16),
          bodyLarge: TextStyle(color: AppColors.foreground, fontSize: 16),
          bodyMedium: TextStyle(color: AppColors.foreground, fontSize: 14),
          bodySmall: TextStyle(color: AppColors.mutedForeground, fontSize: 12),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.secondary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          labelStyle: const TextStyle(color: AppColors.mutedForeground),
          hintStyle: const TextStyle(color: AppColors.mutedForeground),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.card,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.mutedForeground,
        ),
      );
}
