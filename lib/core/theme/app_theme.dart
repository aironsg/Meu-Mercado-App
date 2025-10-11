import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: AppColors.purple500,
            brightness: Brightness.light,
          ).copyWith(
            primary: AppColors.purple500,
            secondary: AppColors.blue500,
            background: AppColors.lightBackground,
            surface: AppColors.white,
          ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.purple500,
        foregroundColor: AppColors.white,
      ),
      //  cardTheme: CardTheme(
      //  color: AppColors.white,
      // elevation: 3,
      //  shape: RoundedRectangleBorder(
      //  borderRadius: BorderRadius.circular(16),
      //  ),
      //  shadowColor: AppColors.purple200.withOpacity(0.4),
      //  ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gradientStart,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.gradientEnd,
        foregroundColor: AppColors.white,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          color: AppColors.textPrimaryLight,
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: TextStyle(color: AppColors.textSecondaryLight),
        labelLarge: TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }
}
