import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../app/theme/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/utils/media_url_helper.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../../home/models/available_booking_response_model.dart';
import '../../sbooking/booking_details_controller.dart';
import '../controller/my_booking_details_controller.dart';
import '../../tracking/live_tracking_map.dart';

class MyBookingDetailsPage extends GetView<MyBookingDetailsController> {
  const MyBookingDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CommonAppBar(
        title: "booking details",
        showLanguageToggle: true,
      ),
      bottomNavigationBar: Obx(() {
        final booking = controller.booking.value;
        if (booking == null) return const SizedBox.shrink();

        final status = booking.status.trim().toLowerCase();
        final showCancel = status == 'bid_selected';
        final showChat = controller.selectedBidId != null &&
            ['bid_selected', 'in_progress', 'completed'].contains(status);

        if (!showCancel && !showChat) return const SizedBox.shrink();

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                if (showCancel) ...[
                  Expanded(
                    child: Obx(() => OutlinedButton.icon(
                      onPressed: controller.isCancellingBid.value
                          ? null
                          : () async {
                              final reason = await _promptReason(
                                context,
                                'Cancel Booking',
                                'Why are you cancelling? (Payment non-refundable)',
                              );
                              if (reason == null) return;
                              await controller.cancelBid(reason: reason);
                            },
                      icon: controller.isCancellingBid.value
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Cancel'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.error,
                        side: BorderSide(color: colorScheme.error),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    )),
                  ),
                  if (showChat) const SizedBox(width: 10),
                ],
                if (showChat)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Get.toNamed(
                        AppRoutes.chatPage,
                        arguments: {
                          'bidId': controller.selectedBidId,
                          'bookingStatus': booking.status,
                        },
                      ),
                      icon: const Icon(Icons.chat_bubble_outline, size: 18),
                      label: const Text('Chat'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
      body: Obx(() {
        final booking = controller.booking.value;
        if (controller.isLoading.value && booking == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (booking == null) {
          return _ErrorState(onRetry: controller.fetchBooking);
        }
        return RefreshIndicator(
          onRefresh: controller.fetchBooking,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _ServiceCard(booking: booking),

              _BookingCard(booking: booking),

              if (controller.isPaymentDue) ...[
                const SizedBox(height: 14),
                _PaymentDueBanner(controller: controller),
              ],


              // Track Technician button (shown when in_progress and booking has coordinates)
              if ((booking.status.trim().toLowerCase() == 'in_progress' ||
                  booking.status.trim().toLowerCase() == 'bid_selected') &&
                  booking.locationLat != null) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CustomerTrackingMap(
                          bookingId: booking.id,
                          customerLat: booking.locationLat!,
                          customerLng: booking.locationLng!,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Track Technician'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],


              if (booking.status.trim().toLowerCase() == 'in_progress') ...[
                const SizedBox(height: 14),
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: controller.isCompletingTask.value
                          ? null
                          : () async {
                              final confirmed =
                                  await _confirmTaskCompletion(context);
                              if (!confirmed) return;

                              final success =
                                  await controller.completeTask();
                              if (!success) return;

                              Get.snackbar(
                                TKeys.taskCompleted.tr,
                                TKeys.taskCompletedMsg.tr,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            },
                      icon: controller.isCompletingTask.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.task_alt_rounded),
                      label: Text(
                        controller.isCompletingTask.value
                            ? 'Completing...'
                            : 'Task Completed',
                      ),
                    ),
                  ),
                ),
              ],

              if (booking.status.trim().toLowerCase() == 'completed' &&
                  (!booking.providerRated || !booking.serviceRated)) ...[
                const SizedBox(height: 14),
                _FeedbackSection(
                  booking: booking,
                  controller: controller,
                ),
              ],

              if (booking.status.trim().toLowerCase() == 'completed' &&
                  controller.assignedTechnicianId != null) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Get.bottomSheet(
                      _ComplaintSheet(controller: controller),
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    icon: const Icon(Icons.report_outlined),
                    label: Text(TKeys.reportTechnician.tr),
                  ),
                ),
              ],

              _SectionTitle(
                icon: Icons.gavel_outlined,
                title: "Submitted bids",
                count: booking.bids.length,
              ),
              // View on map button — always shown if booking has coordinates
              if (booking.locationLat != null) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => BiddersMapPage(
                        bids: booking.bids,
                        customerLat: booking.locationLat,
                        customerLng: booking.locationLng,
                      ),
                    )),
                    icon: const Icon(Icons.map_rounded, size: 18),
                    label: Text(
                      booking.bids.any((b) => b.providerLat != null)
                          ? 'View My Location & Bidders on Map'
                          : 'View My Location on Map',
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              if (booking.bids.isEmpty)
                const _EmptyBids()
              else
                ...booking.bids.map(
                  (bid) => _BidCard(
                    bid: bid,
                    isMine: bid.id == booking.myBidId,
                    onTap: () {
                      controller.viewBidder(bid);

                      Get.bottomSheet(
                        _BidderProfileSheet(
                          bid: bid,
                          controller: controller,
                        ),
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

  Future<String?> _promptReason(BuildContext context, String title, String hint) async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(TKeys.cancel.tr)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text(TKeys.confirm.tr),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmTaskCompletion(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(TKeys.markTaskComplete.tr),
        content: const Text(
          'Confirm that the technician has finished this job.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(TKeys.cancel.tr),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(TKeys.confirm.tr),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}

class _PaymentDueBanner extends StatelessWidget {
  final MyBookingDetailsController controller;

  const _PaymentDueBanner({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.primary.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payments_outlined, color: colors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Payment required',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'You selected a technician for this booking. Pay the booking fee to let them start.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Get.bottomSheet(
                _BookingPaymentSheet(controller: controller),
                isScrollControlled: true,
                isDismissible: false,
                enableDrag: false,
                backgroundColor: Colors.transparent,
              ),
              icon: const Icon(Icons.payment_outlined),
              label: const Text('Pay Now'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackSection extends StatelessWidget {
  final AvailableBookingModel booking;
  final MyBookingDetailsController controller;

  const _FeedbackSection({
    required this.booking,
    required this.controller,
  });

  void _openCombinedSheet() {
    Get.bottomSheet(
      _CombinedFeedbackSheet(
        controller: controller,
        needsServiceReview: !booking.serviceRated,
        needsTechRating: !booking.providerRated,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(colors),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rate your experience',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Complete the remaining feedback for this booking.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _openCombinedSheet,
              icon: const Icon(Icons.rate_review_outlined),
              label: Text('Rate & Review'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CombinedFeedbackSheet extends StatefulWidget {
  final MyBookingDetailsController controller;
  final bool needsServiceReview;
  final bool needsTechRating;

  const _CombinedFeedbackSheet({
    required this.controller,
    required this.needsServiceReview,
    required this.needsTechRating,
  });

  @override
  State<_CombinedFeedbackSheet> createState() => _CombinedFeedbackSheetState();
}

class _CombinedFeedbackSheetState extends State<_CombinedFeedbackSheet> {
  final _formKey = GlobalKey<FormState>();
  final _serviceReviewController = TextEditingController();
  final _techCommentController = TextEditingController();
  int _serviceRating = 5;
  int _techRating = 5;

  @override
  void dispose() {
    _serviceReviewController.dispose();
    _techCommentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    bool success = true;

    if (widget.needsServiceReview) {
      success = await widget.controller.submitServiceReview(
        rating: _serviceRating,
        review: _serviceReviewController.text,
      );
    }

    if (success && widget.needsTechRating) {
      success = await widget.controller.submitProviderRating(
        rating: _techRating,
        comment: _techCommentController.text,
      );
    }

    if (!success || !mounted) return;
    Navigator.of(context).pop();
    Get.snackbar(
      TKeys.thankYou.tr,
      TKeys.serviceReviewSubmitted.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Widget _starRow(int current, void Function(int) onSelect) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final v = i + 1;
        return IconButton(
          tooltip: '$v ${TKeys.starRating.tr}',
          onPressed: () => onSelect(v),
          icon: Icon(
            v <= current ? Icons.star_rounded : Icons.star_border_rounded,
            color: Colors.amber.shade700,
            size: 32,
          ),
        );
      }),
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
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44, height: 4,
                    decoration: BoxDecoration(
                      color: colors.outlineVariant,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Rate your experience',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 20),

                  // ── Service review ─────────────────────────────────────
                  if (widget.needsServiceReview) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(TKeys.reviewService.tr,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    _starRow(_serviceRating, (v) => setState(() => _serviceRating = v)),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _serviceReviewController,
                      minLines: 2, maxLines: 4,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Please write a service review'
                          : null,
                      decoration: InputDecoration(
                        labelText: TKeys.reviewService.tr,
                        hintText: 'Tell us about the service',
                        alignLabelWithHint: true,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],

                  if (widget.needsTechRating) ...[
                    SizedBox(height: widget.needsServiceReview ? 20 : 0),
                    if (widget.needsServiceReview)
                      const Divider(height: 1),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(TKeys.rateTechnician.tr,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    _starRow(_techRating, (v) => setState(() => _techRating = v)),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _techCommentController,
                      minLines: 2, maxLines: 4,
                      decoration: InputDecoration(
                        labelText: '${TKeys.rateTechnician.tr} (optional)',
                        hintText: 'Add a comment about the technician',
                        alignLabelWithHint: true,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  Obx(() {
                    final submitting =
                        widget.controller.isSubmittingServiceReview.value ||
                        widget.controller.isSubmittingProviderRating.value;
                    return SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: submitting ? null : _submit,
                        child: submitting
                            ? const SizedBox(width: 20, height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2))
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

class _CouponTicket extends StatelessWidget {
  final dynamic coupon; // CouponModel
  final int basePrice;
  final VoidCallback onRedeem;

  const _CouponTicket({
    required this.coupon,
    required this.basePrice,
    required this.onRedeem,
  });

  String get _discountLabel {
    if (coupon.type == 'percentage') {
      return '${coupon.percentage.toInt()}% OFF';
    }
    return '৳${coupon.amount.toInt()} OFF';
  }

  String? get _daysLeft {
    final end = coupon.endDate as DateTime?;
    if (end == null) return null;
    final diff = end.difference(DateTime.now()).inDays;
    if (diff < 0) return null;
    if (diff == 0) return 'Last day';
    return '$diff days left';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final daysLeft = _daysLeft;

    return GestureDetector(
      onTap: onRedeem,
      child: CustomPaint(
      painter: _TicketPainter(
        color: colors.surface,
        borderColor: colors.primary.withValues(alpha: 0.4),
        notchRadius: 10,
        dashColor: colors.primary.withValues(alpha: 0.3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        child: Row(
          children: [
            // Left panel — icon
            SizedBox(
              width: 56,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.local_offer_rounded,
                        color: colors.onPrimaryContainer, size: 15),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    coupon.code,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Middle content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _discountLabel,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colors.primary,
                      ),
                    ),
                    if (coupon.type == 'percentage')
                      Text(
                        'Save ৳${coupon.discountFor(basePrice)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      TKeys.tapToApply.tr,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Right panel — days left (rotated)
            if (daysLeft != null)
              SizedBox(
                width: 22,
                child: RotatedBox(
                  quarterTurns: 1,
                  child: Text(
                    daysLeft.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      fontSize: 8,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ),
              )
            else
              const SizedBox(width: 12),
          ],
        ),
      ),
    ),
    );
  }
}

class _PaymentIcon extends StatelessWidget {
  final ColorScheme colors;
  const _PaymentIcon({required this.colors});
  @override
  Widget build(BuildContext context) => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.payment_outlined,
            color: colors.onPrimaryContainer, size: 20),
      );
}

class _TicketPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final Color dashColor;
  final double notchRadius;

  const _TicketPainter({
    required this.color,
    required this.borderColor,
    required this.notchRadius,
    required this.dashColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const r = 12.0; // corner radius
    final nr = notchRadius;
    final midX = 56.0; // divider position

    // Build path with notches at midX
    final path = Path()
      ..moveTo(r, 0)
      ..lineTo(midX - nr, 0)
      ..arcToPoint(Offset(midX + nr, 0),
          radius: Radius.circular(nr), clockwise: false)
      ..lineTo(size.width - r, 0)
      ..arcToPoint(Offset(size.width, r), radius: const Radius.circular(r))
      ..lineTo(size.width, size.height - r)
      ..arcToPoint(Offset(size.width - r, size.height),
          radius: const Radius.circular(r))
      ..lineTo(midX + nr, size.height)
      ..arcToPoint(Offset(midX - nr, size.height),
          radius: Radius.circular(nr), clockwise: false)
      ..lineTo(r, size.height)
      ..arcToPoint(Offset(0, size.height - r), radius: const Radius.circular(r))
      ..lineTo(0, r)
      ..arcToPoint(const Offset(r, 0), radius: const Radius.circular(r))
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);

    // Dashed divider
    final dashPaint = Paint()
      ..color = dashColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashH = 5.0;
    const gap = 4.0;
    double y = nr * 2;
    while (y < size.height - nr * 2) {
      canvas.drawLine(Offset(midX, y), Offset(midX, y + dashH), dashPaint);
      y += dashH + gap;
    }
  }

  @override
  bool shouldRepaint(_TicketPainter old) =>
      old.color != color || old.borderColor != borderColor;
}

class _ComplaintSheet extends StatefulWidget {
  final MyBookingDetailsController controller;

  const _ComplaintSheet({required this.controller});

  @override
  State<_ComplaintSheet> createState() => _ComplaintSheetState();
}

class _ComplaintSheetState extends State<_ComplaintSheet> {
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
    if (!_formKey.currentState!.validate()) return;

    final success = await widget.controller.submitComplaint(
      title: _titleController.text,
      reason: _reasonController.text,
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
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(26),
            ),
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
                    TKeys.reportTechnician.tr,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _titleController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: TKeys.complaintTitle.tr,
                      hintText: 'e.g. Rude behavior, late arrival',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _reasonController,
                    minLines: 3,
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please describe the issue';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: TKeys.complaintReason.tr,
                      hintText: 'Tell us what went wrong',
                      alignLabelWithHint: true,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Obx(() {
                    final submitting =
                        widget.controller.isSubmittingComplaint.value;

                    return SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.error,
                        ),
                        onPressed: submitting ? null : _submit,
                        child: submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
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

class _BookingPaymentSheet extends StatefulWidget {
  final MyBookingDetailsController controller;

  const _BookingPaymentSheet({required this.controller});

  @override
  State<_BookingPaymentSheet> createState() => _BookingPaymentSheetState();
}

class _BookingPaymentSheetState extends State<_BookingPaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _transactionIdController = TextEditingController();
  final _couponController = TextEditingController();
  bool _isCash = false;

  @override
  void dispose() {
    _transactionIdController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_isCash && !_formKey.currentState!.validate()) return;
    if (_isCash) {
      widget.controller.selectedPaymentMethod.value =
          widget.controller.paymentMethodsList
              .cast<dynamic>()
              .firstWhere((m) => m.name.toLowerCase() == 'cash', orElse: () => null);
    }

    final success = await widget.controller.confirmBookingPayment(
      transactionId: _isCash ? '' : _transactionIdController.text,
      isCash: _isCash,
    );

    if (!success || !mounted) return;

    Navigator.of(context).pop();
    Get.snackbar(
      TKeys.success.tr,
      'Payment confirmed. The technician can now start the job.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final controller = widget.controller;
    final bookingFee = controller.booking.value?.bookingFee ?? 0;
    final selectedBid = controller.booking.value?.selectedBid;
    final bidPrice = selectedBid?.price ?? 0;
    final total = bookingFee + bidPrice;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(26),
            ),
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
                    TKeys.payConfirm.tr,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'A technician has been selected. Pay the platform fee + bid amount to confirm.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Booking fee row
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colors.borderColor,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                TKeys.platformFee.tr,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Text('৳$bookingFee',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                TKeys.jobBudget.tr,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Text('৳$bidPrice',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        // Discount row (shown when coupon applied)
                        Obx(() {
                          final discount = controller.discountAmount;
                          if (discount <= 0) return const SizedBox.shrink();
                          return Column(
                            children: [
                              const SizedBox(height: 8),
                              Row(children: [
                                Expanded(child: Text(TKeys.discount.tr,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.green.shade600))),
                                Text('-৳$discount',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green.shade600)),
                              ]),
                            ],
                          );
                        }),
                        const Divider(height: 20),
                        Obx(() {
                          final finalAmt = controller.finalPaymentAmount;
                          return Row(
                            children: [
                              Expanded(
                                child: Text(
                                  TKeys.totalAmount.tr,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                '৳$finalAmt',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors.primary,
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Cash after service toggle ──────────────────────────────
                  StatefulBuilder(builder: (_, setState) => GestureDetector(
                    onTap: () => setState(() => _isCash = !_isCash),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: _isCash
                            ? Colors.orange.withValues(alpha: 0.08)
                            : colors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _isCash
                              ? Colors.orange.shade400
                              : colors.borderColor,
                          width: _isCash ? 1.5 : 1,
                        ),
                      ),
                      child: Row(children: [
                        Icon(Icons.payments_outlined,
                            color: _isCash
                                ? Colors.orange.shade700
                                : colors.onSurfaceVariant,
                            size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(TKeys.cashAfterService.tr,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: _isCash
                                        ? Colors.orange.shade700
                                        : colors.onSurface,
                                  )),
                              Text('Pay the technician directly after service',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                      color: colors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isCash,
                          onChanged: (v) => setState(() => _isCash = v),
                          activeColor: Colors.orange.shade600,
                          activeTrackColor:
                              Colors.orange.withValues(alpha: 0.2),
                        ),
                      ]),
                    ),
                  )),

                  const SizedBox(height: 16),

                  // ── Coupon section ─────────────────────────────────────────
                  Obx(() {
                    final appliedCoupon = controller.appliedCoupon.value;
                    if (appliedCoupon != null) {
                      // Show applied coupon chip with remove
                      return GestureDetector(
                        onTap: () {
                          controller.removeCoupon();
                          _couponController.clear();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: Row(children: [
                            Icon(Icons.local_offer_outlined,
                                size: 18, color: Colors.green.shade700),
                            const SizedBox(width: 8),
                            Expanded(child: Text(
                              '${appliedCoupon.code}  —  ${TKeys.couponApplied.tr}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            )),
                            Icon(Icons.close_rounded,
                                size: 18, color: Colors.red.shade400),
                          ]),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Available coupon tickets
                        if (controller.coupons.isNotEmpty) ...[
                          Text(TKeys.availableCoupons.tr,
                              style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 80,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: controller.coupons.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 10),
                              itemBuilder: (_, i) {
                                final c = controller.coupons[i];
                                return SizedBox(
                                  width: 220,
                                  child: _CouponTicket(
                                    coupon: c,
                                    basePrice: controller.basePaymentAmount,
                                    onRedeem: () {
                                      _couponController.text = c.code;
                                      controller.applyCoupon(c.code);
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],

                        // Manual coupon input
                        Row(children: [
                          Expanded(
                            child: TextFormField(
                              controller: _couponController,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                labelText: TKeys.couponCode.tr,
                                prefixIcon: const Icon(Icons.discount_outlined),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                errorText: controller.couponError.value.isEmpty
                                    ? null
                                    : controller.couponError.value,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          FilledButton(
                            onPressed: () =>
                                controller.applyCoupon(_couponController.text),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(70, 52),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(TKeys.applyCoupon.tr),
                          ),
                        ]),
                      ],
                    );
                  }),

                  if (!_isCash) ...[
                  const SizedBox(height: 16),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      TKeys.paymentMethod.tr,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                        final isSelected =
                            controller.selectedPaymentMethod.value?.id == m.id;
                        final plainDesc = (m.description.isNotEmpty ? m.description : m.account)
                            .replaceAll(RegExp(r'<[^>]*>'), '').trim();
                        return GestureDetector(
                          onTap: () =>
                              controller.selectedPaymentMethod.value = m,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colors.primary.withValues(alpha: 0.06)
                                  : colors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? colors.primary
                                    : colors.borderColor,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(children: [
                              // Icon/image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: m.image.isNotEmpty
                                    ? Image.network(
                                        m.image,
                                        width: 36,
                                        height: 36,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) =>
                                            _PaymentIcon(colors: colors),
                                      )
                                    : _PaymentIcon(colors: colors),
                              ),
                              const SizedBox(width: 12),
                              // Name + description
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      m.name,
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? colors.primary
                                            : colors.onSurface,
                                      ),
                                    ),
                                    if (isSelected && m.description.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Html(
                                        data: m.description,
                                        style: {
                                          'body': Style(
                                            margin: Margins.zero,
                                            padding: HtmlPaddings.zero,
                                            fontSize: FontSize(theme.textTheme.bodySmall?.fontSize ?? 12),
                                            color: colors.onSurface,
                                            lineHeight: const LineHeight(1.3),
                                          ),
                                          'p': Style(margin: Margins.only(bottom: 2), padding: HtmlPaddings.zero),
                                          'li': Style(margin: Margins.only(bottom: 1), padding: HtmlPaddings.zero, lineHeight: const LineHeight(1.3)),
                                          'ol': Style(margin: Margins.only(left: 14, top: 2, bottom: 2), padding: HtmlPaddings.zero),
                                          'ul': Style(margin: Margins.only(left: 14, top: 2, bottom: 2), padding: HtmlPaddings.zero),
                                        },
                                      ),
                                    ] else if (!isSelected && plainDesc.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        plainDesc,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: colors.onSurfaceVariant,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              // Selected indicator
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
                    validator: (v) => v == null || v.trim().isEmpty
                        ? TKeys.transactionIdRequired.tr
                        : null,
                  ),
                  ], // end if (!_isCash)

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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Obx(() => Text(
                                '${TKeys.payNow.tr} ৳${controller.finalPaymentAmount}')),
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

class _BidderProfileSheet extends StatelessWidget {
  final BookingBidModel bid;
  final MyBookingDetailsController controller;

  const _BidderProfileSheet({
    required this.bid,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final avatarUrl = MediaUrlHelper.resolve(bid.providerAvatar);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(26),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle + close
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

            // Profile header: avatar left, name + stats right
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: colors.primaryContainer,
                  backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl.isEmpty
                      ? Icon(Icons.engineering_outlined, size: 38, color: colors.onPrimaryContainer)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bid.providerName,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, size: 16, color: Colors.amber.shade700),
                          const SizedBox(width: 4),
                          Text(
                            bid.rating.toStringAsFixed(1),
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'rating',
                            style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.task_alt_rounded, size: 16, color: Colors.green.shade600),
                          const SizedBox(width: 4),
                          Text(
                            '${bid.totalJobsCompleted}',
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'jobs done',
                            style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Column(
                children: [
                  _ProfileInformationRow(
                    icon: Icons.payments_outlined,
                    label: 'Bid amount',
                    value: '৳${bid.price}',
                  ),
                  if (bid.estimatedArrival.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _ProfileInformationRow(
                      icon: Icons.access_time_outlined,
                      label: 'Estimated arrival',
                      value: bid.estimatedArrival,
                    ),
                  ],
                  if (bid.message.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _ProfileInformationRow(
                      icon: Icons.message_outlined,
                      label: 'Bid message',
                      value: bid.message,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 18),

            Obx(() {
              final bookingStatus =
                  controller.booking.value?.status.trim().toLowerCase() ?? '';
              final canBookTechnician = bookingStatus == 'bidding_open';

              if (!canBookTechnician) {
                return const SizedBox.shrink();
              }

              return SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: controller.isBookingTechnician.value
                      ? null
                      : () async {
                          final success =
                              await controller.bookTechnician(bid);
                          if (!success) return;

                          if (Get.isBottomSheetOpen ?? false) {
                            Get.back();
                          }
                          Get.snackbar(
                            TKeys.success.tr,
                            TKeys.technicianBooked.tr,
                            snackPosition: SnackPosition.BOTTOM,
                          );

                          Get.bottomSheet(
                            _BookingPaymentSheet(controller: controller),
                            isScrollControlled: true,
                            isDismissible: false,
                            enableDrag: false,
                            backgroundColor: Colors.transparent,
                          );
                        },
                  icon: controller.isBookingTechnician.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.event_available_rounded),
                  label: Text(
                    controller.isBookingTechnician.value
                        ? 'Booking...'
                        : 'Book Now',
                  ),
                ),
              );
            }),
          ],
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
width: 100,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon,color: colors.primary, size: 15,),
SizedBox(width: 4,),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          Spacer(),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),


        ],
      ),
    );
  }
}

class _ProfileInformationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInformationRow({
    required this.icon,
    required this.label,
    required this.value,
  });

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
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _ServiceCard extends StatelessWidget {
  final AvailableBookingModel booking;

  const _ServiceCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final imageUrl = MediaUrlHelper.resolve(booking.serviceImage);

    return Container(
      decoration: _cardDecoration(colors),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  width: 76,
                  height: 76,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _ServiceIcon(colors: colors),
                )
                    : _ServiceIcon(colors: colors),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.serviceTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${TKeys.customerBudget.tr}: ${booking.budgetLabel}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (booking.orderNumber.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '#${booking.orderNumber}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final AvailableBookingModel booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final location = [booking.address, booking.district]
        .where((part) => part.trim().isNotEmpty)
        .join(', ');

    return Container(

      decoration: _cardDecoration(colors),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _SectionTitle(
            icon: Icons.engineering_outlined,
            title: "Requirments",

          ),

          const SizedBox(height: 6),
          Text(
            booking.details.trim().isEmpty
                ? TKeys.noDescription.tr
                : booking.details,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
          if (booking.subServices.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
              booking.subServices.map((item) => Chip(label: Text(item))).toList(),
            ),
          ],
          const Divider(height: 18),
          _InfoRow(
            icon: Icons.event_outlined,
            text: '${booking.scheduleDate}  ${booking.scheduleTime}'.trim(),
          ),
          if (location.isNotEmpty) ...[
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.location_on_outlined,
              text: location,
            ),
          ],
          if (booking.status.isNotEmpty) ...[
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.pending_actions_outlined,
              text: booking.status.replaceAll('_', ' '),
            ),
          ],
        ],
      ),
    );
  }
}


class _BidCard extends StatelessWidget {
  final BookingBidModel bid;
  final bool isMine;
  final VoidCallback onTap;

  const _BidCard({
    required this.bid,
    required this.isMine,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final avatarUrl = MediaUrlHelper.resolve(bid.providerAvatar);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isMine
                ? Colors.green.shade50
                : colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isMine
                  ? Colors.green.shade300
                  : colors.borderColor,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 23,
                    backgroundImage: avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl)
                        : null,
                    child: avatarUrl.isEmpty
                        ? const Icon(Icons.engineering_outlined)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bid.providerName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Tap to view profile',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '৳${bid.price}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
              if (bid.estimatedArrival.isNotEmpty) ...[
                const SizedBox(height: 10),
                _InfoRow(
                  icon: Icons.access_time_outlined,
                  text: 'Estimated arrival: ${bid.estimatedArrival}',
                ),
              ],
              if (bid.message.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  bid.message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
class _BidSheet extends StatefulWidget {
  final bool isEditMode;
  final int? initialPrice;
  final String? initialEta;
  final String? initialMessage;

  const _BidSheet({
    required this.isEditMode,
    this.initialPrice,
    this.initialEta,
    this.initialMessage,
  });

  @override
  State<_BidSheet> createState() => _BidSheetState();
}

class _BidSheetState extends State<_BidSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _price;
  late final TextEditingController _eta;
  late final TextEditingController _message;

  @override
  void initState() {
    super.initState();
    _price = TextEditingController(
      text: widget.initialPrice?.toString() ?? '',
    );
    _eta = TextEditingController(text: widget.initialEta ?? '');
    _message = TextEditingController(text: widget.initialMessage ?? '');
  }

  @override
  void dispose() {
    _price.dispose();
    _eta.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      _eta.text = picked.format(context);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = Get.find<BookingDetailsController>();
    final success = await controller.submitBid(
      price: double.parse(_price.text.trim()),
      estimatedArrival: _eta.text.trim(),
      message: _message.text.trim(),
    );
    if (!success || !mounted) return;
    Navigator.of(context).pop();
    Get.snackbar(
      widget.isEditMode ? TKeys.bidUpdated.tr : TKeys.bidSubmitted.tr,
      widget.isEditMode ? TKeys.bidUpdatedMsg.tr : TKeys.bidSubmittedMsg.tr,
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
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.outlineVariant,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.isEditMode
                        ? TKeys.editYourBid.tr
                        : TKeys.placeYourBid.tr,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _price,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final amount = double.tryParse(value?.trim() ?? '');
                      return amount == null || amount <= 0
                          ? TKeys.enterBidPriceError.tr
                          : null;
                    },
                    decoration: InputDecoration(
                      labelText: TKeys.bidPrice.tr,
                      prefixText: '৳ ',
                      prefixIcon: const Icon(Icons.currency_exchange),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _eta,
                    readOnly: true,
                    onTap: _pickTime,
                    validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? TKeys.selectEstimatedTimeError.tr
                        : null,
                    decoration: InputDecoration(
                      labelText: TKeys.estimatedArrival.tr,
                      prefixIcon: const Icon(Icons.access_time_outlined),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _message,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: TKeys.note.tr,
                      hintText: TKeys.noteHint.tr,
                      alignLabelWithHint: true,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Obx(() {
                    final loading = Get.find<BookingDetailsController>()
                        .isBidLoading
                        .value;
                    return Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: loading
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: Text(TKeys.cancel.tr),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: loading ? null : _submit,
                            child: loading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                                : Text(
                              widget.isEditMode
                                  ? TKeys.updateBid.tr
                                  : TKeys.submitBid.tr,
                            ),
                          ),
                        ),
                      ],
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
  final int? count;

  const _SectionTitle({
    required this.icon,
    required this.title,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (count != null) Chip(label: Text('$count')),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}


class _ServiceIcon extends StatelessWidget {
  final ColorScheme colors;

  const _ServiceIcon({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      color: colors.primaryContainer,
      child: Icon(
        Icons.home_repair_service_outlined,
        color: colors.onPrimaryContainer,
      ),
    );
  }
}

class _EmptyBids extends StatelessWidget {
  const _EmptyBids();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(colors),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: colors.onSurfaceVariant),
          const SizedBox(width: 10),
          Text(TKeys.noBidsYet.tr),
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
          const Icon(Icons.error_outline, size: 46),
          const SizedBox(height: 10),
          Text(TKeys.serviceNotFound.tr),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onRetry,
            child: Text(TKeys.retry.tr),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration(ColorScheme colors) {
  return BoxDecoration(
    color: colors.surfaceContainerLowest,
    borderRadius: BorderRadius.circular(14),

  );
}
