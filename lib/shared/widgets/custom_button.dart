import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme/app_colors.dart';

enum ButtonVariant { primary, secondary, outline, ghost, danger }
enum ButtonSize    { sm, md, lg }

class CustomButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isLoading;
  final bool isFullWidth;
  final BorderRadius? borderRadius;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant    = ButtonVariant.primary,
    this.size       = ButtonSize.md,
    this.prefixIcon,
    this.suffixIcon,
    this.isLoading  = false,
    this.isFullWidth = false,
    this.borderRadius,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.04,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _controller.forward();


  @override
  Widget build(BuildContext context) {
    final theme       = Theme.of(context);
    final isDisabled  = widget.onPressed == null || widget.isLoading;

    // ── Size tokens ──────────────────────────────────────────────────────
    final (hPad, vPad, fontSize, iconSize, loaderSize) = switch (widget.size) {
      ButtonSize.sm => (8.0, 6.0,  11.0, 14.0, 12.0),
      ButtonSize.md => (20.0, 12.0, 15.0, 18.0, 16.0),
      ButtonSize.lg => (28.0, 16.0, 17.0, 20.0, 18.0),
    };

    // ── Variant tokens ───────────────────────────────────────────────────
    final (bg, fg, border) = switch (widget.variant) {
      ButtonVariant.primary   => (AppColors.primary,   AppColors.white,   AppColors.primary),
      ButtonVariant.secondary => (AppColors.primary, AppColors.white, AppColors.secondary),
      ButtonVariant.outline   => (Colors.transparent, AppColors.white, AppColors.primary),
      ButtonVariant.ghost     => (Colors.transparent, AppColors.white, Colors.transparent),
      ButtonVariant.danger    => (AppColors.error,     AppColors.white,     AppColors.error),
    };

    final effectiveBg = isDisabled
        ? AppColors.primary
        : bg;
    final effectiveFg = isDisabled
        ? AppColors.white
        : fg;
    final effectiveBorder = isDisabled
        ? Colors.transparent
        : border;

    final radius = widget.borderRadius ?? BorderRadius.circular(4);

    return GestureDetector(
      onTapDown:   isDisabled ? null : _onTapDown,
      onTap:       isDisabled ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: widget.isFullWidth ? double.infinity : null,
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          decoration: BoxDecoration(
            color:        effectiveBg,
            borderRadius: radius,
            border:       Border.all(color: effectiveBorder, width: 1.5),
            boxShadow: isDisabled || widget.variant == ButtonVariant.ghost ||
                widget.variant == ButtonVariant.outline
                ? null
                : [
              BoxShadow(
                color:       effectiveBg.withOpacity(0.35),
                blurRadius:  10,
                offset:      const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            mainAxisSize:     widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading) ...[
                SizedBox(
                  width:  loaderSize,
                  height: loaderSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color:       effectiveFg,
                  ),
                ),
                const SizedBox(width: 8),
              ] else if (widget.prefixIcon != null) ...[
                IconTheme(
                  data: IconThemeData(color: effectiveFg, size: iconSize),
                  child: widget.prefixIcon!,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label.tr,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontSize:   fontSize,
                  fontWeight: FontWeight.w600,
                  color:      effectiveFg,
                  letterSpacing: 0.3,
                ),
              ),
              if (widget.suffixIcon != null && !widget.isLoading) ...[
                const SizedBox(width: 8),
                IconTheme(
                  data: IconThemeData(color: effectiveFg, size: iconSize),
                  child: widget.suffixIcon!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}