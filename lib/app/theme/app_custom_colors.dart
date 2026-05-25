import 'package:flutter/material.dart';

class AppCustomColors extends ThemeExtension<AppCustomColors> {
  final Color success;
  final Color warning;
  final Color info;
  final Color statusPending;
  final Color statusActive;
  final Color statusCancelled;
  final Color statusCompleted;
  final Color cardColor;

  const AppCustomColors({
    required this.success,
    required this.warning,
    required this.info,
    required this.statusPending,
    required this.statusActive,
    required this.statusCancelled,
    required this.statusCompleted,
    required this.cardColor,
  });

  @override
  AppCustomColors copyWith({
    Color? success,
    Color? warning,
    Color? info,
    Color? statusPending,
    Color? statusActive,
    Color? statusCancelled,
    Color? statusCompleted,
    Color? cardColor,
  }) {
    return AppCustomColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      statusPending: statusPending ?? this.statusPending,
      statusActive: statusActive ?? this.statusActive,
      statusCancelled: statusCancelled ?? this.statusCancelled,
      statusCompleted: statusCompleted ?? this.statusCompleted,
      cardColor: cardColor ?? this.cardColor,
    );
  }

  @override
  AppCustomColors lerp(ThemeExtension<AppCustomColors>? other, double t) {
    if (other is! AppCustomColors) return this;

    return AppCustomColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      statusPending: Color.lerp(statusPending, other.statusPending, t)!,
      statusActive: Color.lerp(statusActive, other.statusActive, t)!,
      statusCancelled: Color.lerp(statusCancelled, other.statusCancelled, t)!,
      statusCompleted: Color.lerp(statusCompleted, other.statusCompleted, t)!,
      cardColor: Color.lerp(cardColor, other.cardColor, t)!,
    );
  }
}