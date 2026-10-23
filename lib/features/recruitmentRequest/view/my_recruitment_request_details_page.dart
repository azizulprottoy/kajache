import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';

import '../../../app/theme/context_extension.dart';
import '../../../core/utils/media_url_helper.dart';
import '../../../core/utils/money_format.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/booking_status_helper.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../../../shared/widgets/job_feedback_sheets.dart';
import '../controller/my_recruitment_request_details_controller.dart';
import '../model/recruitment_request_model.dart';
import 'package:kaj_ache/shared/widgets/app_network_image.dart';
import '../../../shared/widgets/technician_portfolio_section.dart';

class MyRecruitmentRequestDetailsPage extends GetView<MyRecruitmentRequestDetailsController> {
  const MyRecruitmentRequestDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CommonAppBar(
        title: TKeys.recruitmentDetailsTitle.tr,
        showLanguageToggle: true,
      ),
      body: Obx(() {
        final req = controller.request.value;
        if (controller.isLoading.value && req == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (req == null) {
          return _ErrorState(onRetry: controller.fetchRequest);
        }

        final status = req.status.trim().toLowerCase();

        return RefreshIndicator(
          onRefresh: controller.fetchRequest,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _JobCard(request: req),

              ..._statusNotices(req, status),

              if (controller.isPaymentDue && controller.isOwner) ...[
                const SizedBox(height: 14),
                _PayToPostBanner(controller: controller),
              ],

              if (controller.isOwner && status == 'hired') ...[
                const SizedBox(height: 14),
                Obx(() => SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: controller.isEnding.value
                            ? null
                            : () async {
                                final confirmed = await showJobConfirmDialog(
                                  context,
                                  title: TKeys.endEngagement.tr,
                                  message: TKeys.confirmEndEngagement.tr,
                                );
                                if (!confirmed) return;
                                final success = await controller.endEngagement();
                                if (!success) return;
                                Get.snackbar(
                                  TKeys.success.tr,
                                  TKeys.engagementEnded.tr,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              },
                        icon: controller.isEnding.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.task_alt_rounded),
                        label: Text(TKeys.endEngagement.tr),
                      ),
                    )),
              ],

              if (controller.canCancel) ...[
                const SizedBox(height: 14),
                Obx(() => SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: controller.isCancelling.value
                            ? null
                            : () async {
                                final reason = await promptJobCancelReason(
                                  context,
                                  title: TKeys.cancelJobPost.tr,
                                  message: switch (status) {
                                    'hired' => TKeys.cancelHiredFeeKeptMsg.tr,
                                    'hiring_open' => TKeys.cancelHiringOpenRefundMsg.tr,
                                    _ => TKeys.cancelJobPostMsg.tr,
                                  },
                                );
                                if (reason == null) return;
                                final success =
                                    await controller.cancelRequest(reason: reason);
                                if (!success) return;
                                Get.snackbar(
                                  TKeys.success.tr,
                                  TKeys.jobPostCancelled.tr,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              },
                        icon: controller.isCancelling.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.cancel_outlined),
                        label: Text(TKeys.cancelJobPost.tr),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.error,
                          side: BorderSide(color: colorScheme.error),
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    )),
              ],

              if (controller.isOwner) ...[
                const SizedBox(height: 14),
                Obx(() => JobFeedbackActions(
                      onRate: controller.canReview
                          ? () => Get.bottomSheet(
                                JobReviewSheet(
                                  isSubmitting: controller.isSubmittingReview,
                                  onSubmit: (rating, review) =>
                                      controller.submitReview(rating: rating, review: review),
                                ),
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                              )
                          : null,
                      onReport: () => Get.bottomSheet(
                        JobComplaintSheet(
                          isSubmitting: controller.isSubmittingComplaint,
                          onSubmit: (title, reason) =>
                              controller.submitComplaint(title: title, reason: reason),
                        ),
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                      ),
                    )),
              ],

              const SizedBox(height: 20),
              _SectionTitle(
                icon: Icons.people_alt_outlined,
                title: TKeys.applicantsLabel.tr,
                count: req.bids.length,
              ),
              const SizedBox(height: 10),

              if (req.bids.isEmpty)
                _EmptyApplicants(status: status)
              else
                ...req.bids.map(
                  (bid) => _ApplicantCard(
                    bid: bid,
                    isSelected: req.selectedBidId == bid.id,
                    onTap: () {
                      controller.viewApplicant(bid);
                      Get.bottomSheet(
                        _ApplicantProfileSheet(bid: bid, controller: controller),
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
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

  /// Cancellation reason and fee refund/forfeit state.
  List<Widget> _statusNotices(RecruitmentRequestDetailsModel req, String status) {
    final paymentStatus = req.paymentStatus.trim().toLowerCase();
    final notices = <Widget>[];

    if (status == 'cancelled') {
      final reason = req.cancellationReason?.trim() ?? '';
      notices.add(JobStatusNotice(
        icon: Icons.cancel_outlined,
        color: Colors.red.shade700,
        title: TKeys.jobCancelledTitle.tr,
        message: reason.isEmpty
            ? TKeys.noReasonGiven.tr
            : '${TKeys.cancellationReasonLabel.tr}: $reason',
      ));
    }

    if (paymentStatus == 'refund_pending') {
      notices.add(JobStatusNotice(
        icon: Icons.currency_exchange_rounded,
        color: Colors.orange.shade700,
        message: TKeys.refundPendingMsg.tr,
      ));
    } else if (paymentStatus == 'refunded') {
      notices.add(JobStatusNotice(
        icon: Icons.check_circle_outline,
        color: Colors.green.shade700,
        message: TKeys.refundedMsg.tr,
      ));
    } else if (paymentStatus == 'forfeited') {
      notices.add(JobStatusNotice(
        icon: Icons.money_off_rounded,
        color: Colors.red.shade700,
        message: TKeys.feeForfeitedMsg.tr,
      ));
    }

    return [
      for (final notice in notices) ...[const SizedBox(height: 14), notice],
    ];
  }
}

class _JobCard extends StatelessWidget {
  final RecruitmentRequestDetailsModel request;

  const _JobCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final imageUrl = MediaUrlHelper.resolve(request.image);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl.isNotEmpty
                    ? AppNetworkImage(
                        imageUrl,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _JobIcon(colors: colors),
                      )
                    : _JobIcon(colors: colors),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.title.isEmpty ? TKeys.jobPost.tr : request.title,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.duration.isEmpty ? TKeys.durationNotSpecified.tr : request.duration,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _StatusChip(info: BookingStatusHelper.of(request.status)),
                        if (request.paymentStatus.trim().toLowerCase() != 'unpaid')
                          _StatusChip(info: BookingStatusHelper.payment(request.paymentStatus)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (request.details.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Html(
              data: request.details,
              style: {
                'body': Style(
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                  color: colors.onSurface,
                  fontSize: FontSize(theme.textTheme.bodyMedium?.fontSize ?? 14),
                  lineHeight: const LineHeight(1.5),
                ),
                'p': Style(margin: Margins.only(bottom: 4), padding: HtmlPaddings.zero),
                'li': Style(margin: Margins.only(bottom: 2), padding: HtmlPaddings.zero, lineHeight: const LineHeight(1.4)),
                'ol': Style(margin: Margins.only(left: 16, top: 4, bottom: 4), padding: HtmlPaddings.zero),
                'ul': Style(margin: Margins.only(left: 16, top: 4, bottom: 4), padding: HtmlPaddings.zero),
              },
            ),
          ],

          const SizedBox(height: 16),
          Divider(height: 1, color: colors.outlineVariant),
          const SizedBox(height: 14),

          if (request.category.isNotEmpty) ...[
            _InfoRow(icon: Icons.category_outlined, text: request.category),
            const SizedBox(height: 10),
          ],

          if (request.locationText.isNotEmpty) ...[
            _InfoRow(icon: Icons.location_on_outlined, text: request.locationText),
            const SizedBox(height: 10),
          ],

          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: TKeys.salaryLabel.tr,
                  value: request.salaryLabel,
                  icon: Icons.payments_outlined,
                ),
              ),
              Container(width: 1, height: 34, color: colors.outlineVariant),
              Expanded(
                child: _StatItem(
                  label: TKeys.platformFee.tr,
                  value: formatTaka(request.platformFee),
                  icon: Icons.account_balance_wallet_outlined,
                ),
              ),
              Container(width: 1, height: 34, color: colors.outlineVariant),
              Expanded(
                child: _StatItem(
                  label: TKeys.applicantsLabel.tr,
                  value: '${request.bidsCount}',
                  icon: Icons.people_alt_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final BookingStatusInfo info;

  const _StatusChip({required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: info.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        info.label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: info.color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _JobIcon extends StatelessWidget {
  final ColorScheme colors;
  const _JobIcon({required this.colors});

  @override
  Widget build(BuildContext context) => Container(
        width: 64,
        height: 64,
        color: colors.primaryContainer,
        child: Icon(Icons.badge_outlined, color: colors.onPrimaryContainer),
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: colors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      children: [
        Icon(icon, size: 18, color: colors.primary),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _PayToPostBanner extends StatelessWidget {
  final MyRecruitmentRequestDetailsController controller;

  const _PayToPostBanner({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payments_outlined, color: colors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                TKeys.paymentRequired.tr,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            TKeys.payToPostSubtitle.tr,
            style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Get.bottomSheet(
                _PayToPostSheet(controller: controller),
                isScrollControlled: true,
                isDismissible: false,
                enableDrag: false,
                backgroundColor: Colors.transparent,
              ),
              icon: const Icon(Icons.payment_outlined),
              label: Text(TKeys.payToPost.tr),
            ),
          ),
        ],
      ),
    );
  }
}

class _PayToPostSheet extends StatefulWidget {
  final MyRecruitmentRequestDetailsController controller;

  const _PayToPostSheet({required this.controller});

  @override
  State<_PayToPostSheet> createState() => _PayToPostSheetState();
}

class _PayToPostSheetState extends State<_PayToPostSheet> {
  final _formKey = GlobalKey<FormState>();
  final _transactionIdController = TextEditingController();

  @override
  void dispose() {
    _transactionIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await widget.controller.payToPost(
      transactionId: _transactionIdController.text,
    );

    if (!success || !mounted) return;

    Navigator.of(context).pop();
    Get.snackbar(
      TKeys.success.tr,
      TKeys.recruitmentPostedMsg.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final controller = widget.controller;
    final fee = controller.request.value?.platformFee ?? 300;

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
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.outlineVariant,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    TKeys.payToPost.tr,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${TKeys.platformFee.tr}: ${formatTaka(fee)}',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold, color: colors.primary),
                  ),
                  const SizedBox(height: 16),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(TKeys.paymentMethod.tr,
                        style:
                            theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),
                  Obx(() {
                    if (controller.isLoadingPaymentMethods.value) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }
                    if (controller.paymentMethodsList.isEmpty) {
                      return Text(TKeys.noData.tr);
                    }
                    return Column(
                      children: controller.paymentMethodsList.map((m) {
                        final isSelected = controller.selectedPaymentMethod.value?.id == m.id;
                        return GestureDetector(
                          onTap: () => controller.selectedPaymentMethod.value = m,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colors.primary.withValues(alpha: 0.06)
                                  : colors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? colors.primary : colors.borderColor,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(children: [
                              Icon(Icons.payment_outlined, color: colors.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: Text(m.name,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(fontWeight: FontWeight.w700))),
                              if (isSelected)
                                Icon(Icons.check_circle_rounded,
                                    color: colors.primary, size: 20),
                            ]),
                          ),
                        );
                      }).toList(),
                    );
                  }),

                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _transactionIdController,
                    decoration: InputDecoration(
                      labelText: TKeys.transactionId.tr,
                      hintText: TKeys.transactionIdHint.tr,
                      prefixIcon: const Icon(Icons.receipt_long_outlined),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? TKeys.transactionIdRequired.tr : null,
                  ),

                  const SizedBox(height: 18),
                  Obx(() {
                    final submitting = controller.isSubmittingPayment.value;
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
                            : Text('${TKeys.payNow.tr} ${formatTaka(fee)}'),
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

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;

  const _SectionTitle({required this.icon, required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: colors.primary),
        const SizedBox(width: 8),
        Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('$count',
              style: theme.textTheme.labelSmall
                  ?.copyWith(fontWeight: FontWeight.bold, color: colors.onPrimaryContainer)),
        ),
      ],
    );
  }
}

class _EmptyApplicants extends StatelessWidget {
  final String status;
  const _EmptyApplicants({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final message = status == 'pending_payment'
        ? TKeys.applicationsAfterLive.tr
        : TKeys.noApplicationsYet.tr;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  final RecruitmentBidModel bid;
  final bool isSelected;
  final VoidCallback onTap;

  const _ApplicantCard({required this.bid, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final avatarUrl = MediaUrlHelper.resolve(bid.applicantAvatar);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? colors.primary : colors.borderColor,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: colors.primaryContainer,
                  backgroundImage: avatarUrl.isNotEmpty ? appNetworkImageProvider(avatarUrl) : null,
                  child: avatarUrl.isEmpty
                      ? Icon(Icons.engineering_outlined, color: colors.onPrimaryContainer)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(bid.applicantName,
                          style:
                              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(
                        bid.proposedSalaryLabel,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: colors.primary, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      TKeys.hiredSuccessfully.tr,
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: Colors.green.shade700, fontWeight: FontWeight.w700),
                    ),
                  )
                else if (bid.status != 'active')
                  _StatusChip(info: BookingStatusHelper.bid(bid.status))
                else
                  Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ApplicantProfileSheet extends StatelessWidget {
  final RecruitmentBidModel bid;
  final MyRecruitmentRequestDetailsController controller;

  const _ApplicantProfileSheet({required this.bid, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final avatarUrl = MediaUrlHelper.resolve(bid.applicantAvatar);

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 42,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.outlineVariant,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      tooltip: TKeys.close.tr,
                      onPressed: Get.back,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            CircleAvatar(
              radius: 46,
              backgroundColor: colors.primaryContainer,
              backgroundImage: avatarUrl.isNotEmpty ? appNetworkImageProvider(avatarUrl) : null,
              child: avatarUrl.isEmpty
                  ? Icon(Icons.engineering_outlined, size: 44, color: colors.onPrimaryContainer)
                  : null,
            ),
            const SizedBox(height: 14),

            Text(bid.applicantName,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),

            if (bid.applicantUsername.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('@${bid.applicantUsername}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
            ],

            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: _ProfileStat(
                    icon: Icons.star_rounded,
                    label: TKeys.rating.tr,
                    value: bid.applicantRating.toStringAsFixed(1),
                    color: Colors.amber.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ProfileStat(
                    icon: Icons.task_alt_rounded,
                    label: TKeys.completedJobs.tr,
                    value: '${bid.applicantTotalJobsCompleted}',
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 10),

            _ProfileInfoRow(
              icon: Icons.payments_outlined,
              label: TKeys.proposedSalaryLabel.tr,
              value: bid.proposedSalaryLabel,
            ),

            if (bid.message.isNotEmpty)
              _ProfileInfoRow(
                icon: Icons.message_outlined,
                label: TKeys.applicationMessageLabel.tr,
                value: bid.message,
              ),

            const SizedBox(height: 18),
            TechnicianPortfolioSection(technicianId: bid.applicantId),
            const SizedBox(height: 18),

            Obx(() {
              final currentStatus =
                  controller.request.value?.status.trim().toLowerCase() ?? '';
              final canHire = currentStatus == 'hiring_open' &&
                  controller.isOwner &&
                  bid.status == 'active';

              if (!canHire) return const SizedBox.shrink();

              return SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: controller.isSelectingBid.value
                      ? null
                      : () async {
                          final confirmed = await showJobConfirmDialog(
                            context,
                            title: TKeys.hireApplicant.tr,
                            message: TKeys.confirmHireMsg.trParams({'name': bid.applicantName}),
                          );
                          if (!confirmed) return;
                          final success = await controller.hireApplicant(bid);
                          if (!success) return;

                          if (Get.isBottomSheetOpen ?? false) Get.back();

                          Get.snackbar(
                            TKeys.hiredSuccessfully.tr,
                            TKeys.hiredSuccessfullyMsg.tr,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                  icon: controller.isSelectingBid.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.handshake_outlined),
                  label: Text(
                    controller.isSelectingBid.value
                        ? '${TKeys.loading.tr}...'
                        : TKeys.hireApplicant.tr,
                  ),
                ),
              );
            }),
          ],
        ),
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ProfileStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 6),
          Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(label,
                style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(value,
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 12),
          Text(TKeys.noData.tr),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: Text(TKeys.retry.tr)),
        ],
      ),
    );
  }
}
