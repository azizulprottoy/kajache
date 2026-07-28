import 'package:flutter/material.dart';
import 'app_custom_colors.dart';

extension ThemeContext on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;

  AppCustomColors get customColors =>
      Theme.of(this).extension<AppCustomColors>()!;
}

extension AdaptiveBorder on ColorScheme {
  /// Visible border color in both light and dark themes.
  Color get borderColor => brightness == Brightness.dark
      ? outlineVariant
      : outlineVariant.withValues(alpha: 0.25);
}