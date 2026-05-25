import 'package:flutter/material.dart';
import 'app_custom_colors.dart';

extension ThemeContext on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;

  AppCustomColors get customColors =>
      Theme.of(this).extension<AppCustomColors>()!;
}