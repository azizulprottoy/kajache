import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/translation_keys.dart';

/// Shared UI for the instant-service and recruitment-request flows:
/// status notices, confirm/cancel dialogs, and the "rate technician" and
/// "report a problem" bottom sheets. Mirrors the booking flow's private
/// `_CombinedFeedbackSheet` / `_ComplaintSheet` look, but takes callbacks so
/// both job types can reuse it.

/// Tinted info box used for state banners ("waiting for payment", etc).
class JobStatusNotice extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;
  final String? title;

  const JobStatusNotice({
    super.key,
    required this.icon,
    required this.color,
    required this.message,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null && title!.isNotEmpty) ...[
                  Text(
                    title!,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Yes/no confirmation. Returns true only when the user confirms.
Future<bool> showJobConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(TKeys.cancel.tr),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(backgroundColor: Theme.of(dialogContext).colorScheme.error)
              : null,
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(TKeys.confirm.tr),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Cancel confirmation with an optional reason. Returns null when dismissed,
/// otherwise the (possibly empty) reason.
Future<String?> promptJobCancelReason(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final reasonController = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 14),
            TextField(
              controller: reasonController,
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(
                labelText: TKeys.cancelReasonLabel.tr,
                hintText: TKeys.cancelReasonHint.tr,
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(TKeys.cancel.tr),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Theme.of(dialogContext).colorScheme.error),
          onPressed: () => Navigator.pop(dialogContext, reasonController.text.trim()),
          child: Text(TKeys.confirm.tr),
        ),
      ],
    ),
  );
  reasonController.dispose();
  return result;
}

Widget _sheetHandle(ColorScheme colors) => Container(
      width: 44,
      height: 4,
      decoration: BoxDecoration(
        color: colors.outlineVariant,
        borderRadius: BorderRadius.circular(20),
      ),
    );

/// Star rating + optional comment for the technician of a finished job.
class JobReviewSheet extends StatefulWidget {
  final RxBool isSubmitting;
  final Future<bool> Function(int rating, String review) onSubmit;

  const JobReviewSheet({
    super.key,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  State<JobReviewSheet> createState() => _JobReviewSheetState();
}

class _JobReviewSheetState extends State<JobReviewSheet> {
  final _commentController = TextEditingController();
  int _rating = 5;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.isSubmitting.value) return;
    final success = await widget.onSubmit(_rating, _commentController.text.trim());
    if (!success || !mounted) return;
    Navigator.of(context).pop();
    Get.snackbar(
      TKeys.thankYou.tr,
      TKeys.technicianReviewSubmitted.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _sheetHandle(colors),
                const SizedBox(height: 18),
                Text(
                  TKeys.rateTechnician.tr,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: List.generate(5, (i) {
                    final value = i + 1;
                    return IconButton(
                      tooltip: '$value ${TKeys.starRating.tr}',
                      onPressed: () => setState(() => _rating = value),
                      icon: Icon(
                        value <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                        color: Colors.amber.shade700,
                        size: 32,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _commentController,
                  minLines: 2,
                  maxLines: 4,
                  maxLength: 2000,
                  decoration: InputDecoration(
                    labelText: TKeys.reviewCommentLabel.tr,
                    hintText: TKeys.reviewCommentHint.tr,
                    alignLabelWithHint: true,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                Obx(() {
                  final submitting = widget.isSubmitting.value;
                  return SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: submitting ? null : _submit,
                      child: submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(TKeys.submit.tr),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Title + description complaint about a job, sent to support.
class JobComplaintSheet extends StatefulWidget {
  final RxBool isSubmitting;
  final Future<bool> Function(String title, String reason) onSubmit;

  const JobComplaintSheet({
    super.key,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  State<JobComplaintSheet> createState() => _JobComplaintSheetState();
}

class _JobComplaintSheetState extends State<JobComplaintSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.isSubmitting.value) return;
    if (!_formKey.currentState!.validate()) return;

    final success = await widget.onSubmit(
      _titleController.text.trim(),
      _reasonController.text.trim(),
    );
    if (!success || !mounted) return;

    Navigator.of(context).pop();
    Get.snackbar(
      TKeys.complaintSubmitted.tr,
      TKeys.complaintSubmittedMsg.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _sheetHandle(colors),
                  const SizedBox(height: 18),
                  Text(
                    TKeys.reportProblem.tr,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _titleController,
                    maxLength: 150,
                    validator: (value) =>
                        value == null || value.trim().isEmpty ? TKeys.complaintTitleRequired.tr : null,
                    decoration: InputDecoration(
                      labelText: TKeys.complaintTitle.tr,
                      hintText: TKeys.complaintTitleHint.tr,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _reasonController,
                    minLines: 3,
                    maxLines: 5,
                    maxLength: 2000,
                    validator: (value) =>
                        value == null || value.trim().isEmpty ? TKeys.complaintReasonRequired.tr : null,
                    decoration: InputDecoration(
                      labelText: TKeys.complaintReason.tr,
                      hintText: TKeys.complaintReasonHint.tr,
                      alignLabelWithHint: true,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Obx(() {
                    final submitting = widget.isSubmitting.value;
                    return SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: colors.error),
                        onPressed: submitting ? null : _submit,
                        child: submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(TKeys.submit.tr),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Rate technician" / "Report a problem" buttons shown at the bottom of a
/// job details page. Either button is hidden when its callback is null.
class JobFeedbackActions extends StatelessWidget {
  final VoidCallback? onRate;
  final VoidCallback? onReport;

  const JobFeedbackActions({super.key, this.onRate, this.onReport});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        if (onRate != null)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onRate,
              icon: const Icon(Icons.star_rate_rounded),
              label: Text(TKeys.rateTechnician.tr),
            ),
          ),
        if (onRate != null && onReport != null) const SizedBox(height: 10),
        if (onReport != null)
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: onReport,
              style: TextButton.styleFrom(foregroundColor: colors.error),
              icon: const Icon(Icons.flag_outlined),
              label: Text(TKeys.reportProblem.tr),
            ),
          ),
      ],
    );
  }
}
