import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';

import '../../../app/theme/context_extension.dart';
import '../../../core/utils/html_text.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/booking_status_helper.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../../../shared/widgets/job_feedback_sheets.dart';
import '../controller/available_recruitment_requests_controller.dart';
import '../model/recruitment_request_model.dart';

/// Fetches the post, then opens the apply sheet. Ignores taps while a sheet
/// is already opening.
Future<void> _openApplySheet(AvailableRecruitmentRequestsController controller, String id) async {
  if (id.isEmpty || controller.isOpeningSheet) return;
  controller.isOpeningSheet = true;
  try {
    await controller.openRequest(id);
    if (controller.selectedRequest.value == null) return;
    await Get.bottomSheet(
      _ApplySheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
    controller.clearSelectedRequest();
  } finally {
    controller.isOpeningSheet = false;
  }
}

class AvailableRecruitmentRequestsPage
    extends GetView<AvailableRecruitmentRequestsController> {
  const AvailableRecruitmentRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // A specific post was passed in (home tile / notification): open it once
    final initialId = controller.takeInitialId();
    if (initialId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openApplySheet(controller, initialId));
    }

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: CommonAppBar(
        title: TKeys.availableRecruitmentRequests.tr,
        showBack: false,
        showLanguageToggle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.availableRequests.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.availableRequests.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.fetchAvailableRequests,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.3),
                Icon(Icons.badge_outlined, size: 64, color: colorScheme.outline),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    TKeys.noOpenJobsFound.tr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchAvailableRequests,
          child: Column(
            children: [
              if (controller.isLoadingDetails.value) const LinearProgressIndicator(),
              Expanded(
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemCount: controller.availableRequests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final item = controller.availableRequests[index];
                    return _JobOpeningCard(
                      item: item,
                      onTap: () => _openApplySheet(controller, item.id),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _JobOpeningCard extends StatelessWidget {
  final RecruitmentRequestModel item;
  final VoidCallback onTap;

  const _JobOpeningCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      elevation: 1,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.borderColor),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.badge_outlined, color: colorScheme.onPrimaryContainer),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title.isEmpty ? TKeys.jobOpening.tr : item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          [
                            item.duration.isEmpty ? TKeys.durationNotSpecified.tr : item.duration,
                            if (item.category.isNotEmpty) item.category,
                          ].join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 110),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        item.salaryLabel,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              if (item.details.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  htmlToPlainText(item.details),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.4),
                ),
              ],

              const SizedBox(height: 12),
              Divider(height: 1, color: colorScheme.outlineVariant),
              const SizedBox(height: 10),

              Row(
                children: [
                  if (item.locationText.isNotEmpty) ...[
                    Icon(Icons.location_on_outlined, size: 16, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.locationText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ] else
                    const Spacer(),
                  if (item.hasBid) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.myBid != null
                            ? '${TKeys.applied.tr}: ${item.myBid!.proposedSalaryLabel}'
                            : TKeys.applied.tr,
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: Colors.green.shade700, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Icon(Icons.people_alt_outlined, size: 16, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    '${item.bidsCount}',
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApplySheet extends StatefulWidget {
  final AvailableRecruitmentRequestsController controller;

  const _ApplySheet({required this.controller});

  @override
  State<_ApplySheet> createState() => _ApplySheetState();
}

class _ApplySheetState extends State<_ApplySheet> {
  final _formKey = GlobalKey<FormState>();
  final _salaryController = TextEditingController();
  final _messageController = TextEditingController();
  bool _prefilled = false;

  @override
  void dispose() {
    _salaryController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _prefillIfNeeded(RecruitmentRequestDetailsModel? detail) {
    if (_prefilled || detail == null) return;
    final myBid = detail.myBid;
    if (myBid != null) {
      _salaryController.text = myBid.proposedSalary.toInt().toString();
      _messageController.text = myBid.message;
    }
    _prefilled = true;
  }

  Future<void> _submit() async {
    if (widget.controller.isSubmittingBid.value) return;
    if (!_formKey.currentState!.validate()) return;

    // Read before submitting: afterwards the refreshed post always has a bid
    final wasUpdate = widget.controller.selectedRequest.value?.hasBid ?? false;

    final success = await widget.controller.submitBid(
      proposedSalary: num.tryParse(_salaryController.text.trim()) ?? 0,
      message: _messageController.text,
    );

    if (!success || !mounted) return;

    Navigator.of(context).pop();
    Get.snackbar(
      wasUpdate ? TKeys.applicationUpdated.tr : TKeys.applicationSubmitted.tr,
      wasUpdate ? '' : TKeys.applicationSubmittedMsg.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Obx(() {
      final controller = widget.controller;
      final detail = controller.selectedRequest.value;

      if (controller.isLoadingDetails.value && detail == null) {
        return const SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      }

      if (detail == null) return const SizedBox.shrink();

      _prefillIfNeeded(detail);
      final isUpdate = detail.hasBid;
      final myBid = detail.myBid;
      final myBidStatus = myBid?.status.trim().toLowerCase() ?? '';
      // Only an open post takes new applications; only an active one can be edited
      final canApply = detail.status.trim().toLowerCase() == 'hiring_open' &&
          (myBid == null || myBidStatus == 'active');

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colors.outlineVariant,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      detail.title.isEmpty ? TKeys.jobOpening.tr : detail.title,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        detail.duration.isEmpty ? TKeys.durationNotSpecified.tr : detail.duration,
                        if (detail.category.isNotEmpty) detail.category,
                        if (detail.locationText.isNotEmpty) detail.locationText,
                      ].join(' · '),
                      style:
                          theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                    ),
                    if (detail.details.trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Html(
                        data: detail.details,
                        style: {
                          'body': Style(
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                            color: colors.onSurfaceVariant,
                            fontSize: FontSize(theme.textTheme.bodyMedium?.fontSize ?? 14),
                            lineHeight: const LineHeight(1.4),
                          ),
                          'p': Style(margin: Margins.only(bottom: 4), padding: HtmlPaddings.zero),
                          'ol': Style(margin: Margins.only(left: 16, top: 4, bottom: 4), padding: HtmlPaddings.zero),
                          'ul': Style(margin: Margins.only(left: 16, top: 4, bottom: 4), padding: HtmlPaddings.zero),
                        },
                      ),
                    ],
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(children: [
                        Expanded(
                          child: Text(TKeys.salaryLabel.tr,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: colors.onSurfaceVariant)),
                        ),
                        Text(detail.salaryLabel,
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold, color: colors.primary)),
                      ]),
                    ),

                    if (myBid != null) ...[
                      const SizedBox(height: 12),
                      JobStatusNotice(
                        icon: Icons.assignment_turned_in_outlined,
                        color: BookingStatusHelper.bid(myBid.status).color,
                        title: '${TKeys.myApplication.tr}: ${BookingStatusHelper.bid(myBid.status).label}',
                        message: '${TKeys.proposedSalaryLabel.tr}: ${myBid.proposedSalaryLabel}',
                      ),
                    ],
                    if (detail.status.trim().toLowerCase() == 'cancelled') ...[
                      const SizedBox(height: 12),
                      JobStatusNotice(
                        icon: Icons.cancel_outlined,
                        color: Colors.red.shade700,
                        title: TKeys.jobCancelledTitle.tr,
                        message: (detail.cancellationReason?.trim() ?? '').isEmpty
                            ? TKeys.noReasonGiven.tr
                            : '${TKeys.cancellationReasonLabel.tr}: ${detail.cancellationReason!.trim()}',
                      ),
                    ],
                    if (myBidStatus == 'selected' || myBidStatus == 'cancelled') ...[
                      const SizedBox(height: 10),
                      JobFeedbackActions(
                        onReport: () => Get.bottomSheet(
                          JobComplaintSheet(
                            isSubmitting: controller.isSubmittingComplaint,
                            onSubmit: (title, reason) =>
                                controller.submitComplaint(title: title, reason: reason),
                          ),
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ],

                    if (canApply) ...[
                    const SizedBox(height: 18),
                    const Divider(height: 1),
                    const SizedBox(height: 16),

                    Text(
                      isUpdate ? TKeys.updateApplication.tr : TKeys.applyNow.tr,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _salaryController,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final n = num.tryParse(v?.trim() ?? '');
                        if (n == null || n <= 0) return TKeys.salaryInvalid.tr;
                        if (n > 10000000) return TKeys.amountTooLarge.tr;
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: TKeys.proposedSalaryLabel.tr,
                        hintText: TKeys.proposedSalaryHint.tr,
                        prefixText: '৳ ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _messageController,
                      minLines: 2,
                      maxLines: 4,
                      maxLength: 500,
                      decoration: InputDecoration(
                        labelText: TKeys.applicationMessageLabel.tr,
                        hintText: TKeys.applicationMessageHint.tr,
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),

                    const SizedBox(height: 18),
                    Obx(() {
                      final submitting = controller.isSubmittingBid.value;
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
                              : Text(isUpdate ? TKeys.updateApplication.tr : TKeys.applyNow.tr),
                        ),
                      );
                    }),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
