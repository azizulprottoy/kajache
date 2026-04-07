import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? barrierColor;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.barrierColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading) ...[
          // Barrier
          Positioned.fill(
            child: AnimatedOpacity(
              opacity:  isLoading ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: ColoredBox(
                color: barrierColor ?? Colors.black.withOpacity(0.45),
              ),
            ),
          ),
          // Spinner card
          const Center(child: _LoadingCard()),
        ],
      ],
    );
  }
}

class _LoadingCard extends StatefulWidget {
  const _LoadingCard();

  @override
  State<_LoadingCard> createState() => _LoadingCardState();
}

class _LoadingCardState extends State<_LoadingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 250),
    )..forward();
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return ScaleTransition(
      scale: _scale,
      child: Container(
        padding:     const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        decoration:  BoxDecoration(
          color:        cs.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color:      Colors.black.withOpacity(0.15),
              blurRadius: 24,
              offset:     const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width:  44,
              height: 44,
              child: CircularProgressIndicator(
                strokeWidth: 3.5,
                color:       cs.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Convenience: full-screen loader ──────────────────────────────────────────
class FullScreenLoader extends StatelessWidget {
  final String? message;
  const FullScreenLoader({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: cs.primary, strokeWidth: 3.5),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!.tr,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}