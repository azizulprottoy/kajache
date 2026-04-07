import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum ErrorType { general, network, notFound, empty, permissionDenied, serverError }

class AppErrorWidget extends StatelessWidget {
  final ErrorType type;
  final String? title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  const AppErrorWidget({
    super.key,
    this.type          = ErrorType.general,
    this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.compact       = false,
  });

  // ── Convenience constructors ──────────────────────────────────────────
  const AppErrorWidget.network({super.key, this.onAction, this.compact = false})
      : type        = ErrorType.network,
        title       = null,
        message     = null,
        actionLabel = null;

  const AppErrorWidget.empty({
    super.key,
    this.title,
    this.message,
    this.onAction,
    this.actionLabel,
    this.compact = false,
  }) : type = ErrorType.empty;

  (IconData, String, String) get _content => switch (type) {
    ErrorType.network         => (Icons.wifi_off_rounded,          'No Connection',        'Check your internet and try again.'),
    ErrorType.notFound        => (Icons.search_off_rounded,         'Not Found',            'The item you\'re looking for doesn\'t exist.'),
    ErrorType.empty           => (Icons.inbox_outlined,             'Nothing Here',         'There\'s nothing to show right now.'),
    ErrorType.permissionDenied=> (Icons.lock_outline_rounded,       'Access Denied',        'You don\'t have permission to view this.'),
    ErrorType.serverError     => (Icons.cloud_off_outlined,         'Server Error',         'Something went wrong on our end.'),
    ErrorType.general         => (Icons.error_outline_rounded,      'Something Went Wrong', 'An unexpected error occurred.'),
  };

  @override
  Widget build(BuildContext context) {
    final theme            = Theme.of(context);
    final cs               = theme.colorScheme;
    final (icon, t, msg)   = _content;
    final effectiveTitle   = title   ?? t;
    final effectiveMessage = message ?? msg;

    if (compact) {
      return Row(
        children: [
          Icon(icon, size: 18, color: cs.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              effectiveMessage,
              style: theme.textTheme.bodySmall?.copyWith(color: cs.error),
            ),
          ),
        ],
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container
            Container(
              width:  80,
              height: 80,
              decoration: BoxDecoration(
                color:  cs.errorContainer.withOpacity(0.3),
                shape:  BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: cs.error),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              effectiveTitle.tr,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color:      cs.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Message
            Text(
              effectiveMessage.tr,
              style: theme.textTheme.bodyMedium?.copyWith(
                color:  cs.onSurface.withOpacity(0.6),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            if (onAction != null) ...[
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: onAction,
                icon:  const Icon(Icons.refresh_rounded, size: 18),
                label: Text((actionLabel ?? 'Try Again').tr),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape:   RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}