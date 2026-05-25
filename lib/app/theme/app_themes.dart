import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_custom_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      surface: AppColors.surface,
      onPrimary: AppColors.textOnPrimary,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.border,
      outlineVariant: AppColors.divider,
    ),
    extensions: const [
      AppCustomColors(
        success: AppColors.success,
        warning: AppColors.warning,
        info: AppColors.info,
        statusPending: AppColors.statusPending,
        statusActive: AppColors.statusActive,
        statusCancelled: AppColors.statusCancelled,
        statusCompleted: AppColors.statusCompleted,
        cardColor: AppColors.surface,
      ),
    ],
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryLight,
      secondary: AppColors.secondaryLight,
      error: AppColors.error,
      surface: AppColors.darkSurface,
      onPrimary: AppColors.textOnPrimary,
      onSurface: AppColors.darkTextPrimary,
      onSurfaceVariant: AppColors.darkTextSecondary,
      outline: AppColors.darkDivider,
      outlineVariant: AppColors.darkDivider,
    ),
    extensions: const [
      AppCustomColors(
        success: AppColors.success,
        warning: AppColors.warning,
        info: AppColors.info,
        statusPending: AppColors.statusPending,
        statusActive: AppColors.statusActive,
        statusCancelled: AppColors.statusCancelled,
        statusCompleted: AppColors.statusCompleted,
        cardColor: AppColors.darkCard,
      ),
    ],
  );
}