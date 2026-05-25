import 'package:flutter/material.dart';

class SuccessModal extends StatelessWidget {
  final String title;
  final String message;

  final String? yesText;
  final String? noText;

  final VoidCallback? onYes;
  final VoidCallback? onNo;
  final VoidCallback? onClose;

  const SuccessModal({
    super.key,
    required this.title,
    required this.message,
    this.onYes,
    this.onNo,
    this.onClose,
    this.yesText,
    this.noText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasNoButton = noText != null && onNo != null;
    final hasYesButton = yesText != null && onYes != null;
    final hasAnyButton = hasNoButton || hasYesButton;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 40,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      height: 1.5,
                    ),
                  ),
                  if (hasAnyButton) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        if (hasNoButton)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: onNo,
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(noText!),
                            ),
                          ),
                        if (hasNoButton && hasYesButton)
                          const SizedBox(width: 12),
                        if (hasYesButton)
                          Expanded(
                            child: FilledButton(
                              onPressed: onYes,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(yesText!),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onClose ?? () => Navigator.of(context).pop(),
                child: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.close,
                    size: 20,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}