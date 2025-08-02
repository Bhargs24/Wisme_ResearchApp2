import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      primaryColor: AppColors.primaryBlue,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryBlue,
        secondary: AppColors.accentGreen,
        background: AppColors.backgroundDark,
        surface: AppColors.backgroundCard,
        error: AppColors.accentRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundCard,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: AppTextStyles.heading2,
      ),
      cardColor: AppColors.backgroundCard,
      dialogBackgroundColor: AppColors.backgroundCard,
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.heading1,
        displayMedium: AppTextStyles.heading2,
        displaySmall: AppTextStyles.bodyLarge,
        headlineLarge: AppTextStyles.heading1,
        headlineMedium: AppTextStyles.heading2,
        headlineSmall: AppTextStyles.bodyLarge,
        titleLarge: AppTextStyles.heading2,
        titleMedium: AppTextStyles.bodyLarge,
        titleSmall: AppTextStyles.caption,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.caption,
        bodySmall: AppTextStyles.caption,
        labelLarge: TextStyle(color: AppColors.accentGreen),
        labelMedium: TextStyle(color: AppColors.accentGreen),
        labelSmall: TextStyle(color: AppColors.accentGreen),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.backgroundCard),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: AppColors.primaryBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.backgroundCard,
        contentTextStyle: TextStyle(color: Colors.white),
        actionTextColor: AppColors.accentGreen,
      ),
    );
  }
} 