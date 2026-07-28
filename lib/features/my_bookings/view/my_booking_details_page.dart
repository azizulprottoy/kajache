import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/media_url_helper.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../../home/models/available_booking_response_model.dart';
import '../../sbooking/booking_details_controller.dart';
import '../controller/my_booking_details_controller.dart';

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

class _FeedbackSection extends StatelessWidget {
  final AvailableBookingModel booking;
  final MyBookingDetailsController controller;

  const _FeedbackSection({
    required this.booking,
    required this.controller,
  });

  void _openForm({
    required bool isServiceReview,
  }) {
    Get.bottomSheet(
      _RatingAndReviewSheet(
        controller: controller,
        isServiceReview: isServiceReview,
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
          if (!booking.serviceRated) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openForm(isServiceReview: true),
                icon: const Icon(Icons.rate_review_outlined),
                label: Text(TKeys.reviewService.tr),
              ),
            ),
          ],
          if (!booking.providerRated) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _openForm(isServiceReview: false),
                icon: const Icon(Icons.star_outline_rounded),
                label: Text(TKeys.rateTechnician.tr),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RatingAndReviewSheet extends StatefulWidget {
  final MyBookingDetailsController controller;
  final bool isServiceReview;

  const _RatingAndReviewSheet({
    required this.controller,
    required this.isServiceReview,
  });

  @override
  State<_RatingAndReviewSheet> createState() =>
      _RatingAndReviewSheetState();
}

class _RatingAndReviewSheetState extends State<_RatingAndReviewSheet> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  int _rating = 5;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = widget.isServiceReview
        ? await widget.controller.submitServiceReview(
            rating: _rating,
            review: _commentController.text,
          )
        : await widget.controller.submitProviderRating(
            rating: _rating,
            comment: _commentController.text,
          );

    if (!success || !mounted) return;

    Navigator.of(context).pop();
    Get.snackbar(
      TKeys.thankYou.tr,
      widget.isServiceReview
          ? TKeys.serviceReviewSubmitted.tr
          : TKeys.techRatingSubmitted.tr,
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
                    widget.isServiceReview
                        ? 'Review Service'
                        : 'Rate Technician',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final value = index + 1;
                      return IconButton(
                        tooltip: '$value ${TKeys.starRating.tr}',
                        onPressed: () => setState(() => _rating = value),
                        icon: Icon(
                          value <= _rating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: Colors.amber.shade700,
                          size: 34,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _commentController,
                    minLines: 3,
                    maxLines: 5,
                    validator: (value) {
                      if (widget.isServiceReview &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Please write a service review';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: widget.isServiceReview
                          ? 'Service review'
                          : 'Comment (optional)',
                      hintText: widget.isServiceReview
                          ? 'Tell us about the service'
                          : 'Add a comment about the technician',
                      alignLabelWithHint: true,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Obx(() {
                    final submitting = widget.isServiceReview
                        ? widget.controller.isSubmittingServiceReview.value
                        : widget.controller.isSubmittingProviderRating.value;

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
              backgroundImage: avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : null,
              child: avatarUrl.isEmpty
                  ? Icon(
                      Icons.engineering_outlined,
                      size: 44,
                      color: colors.onPrimaryContainer,
                    )
                  : null,
            ),
            const SizedBox(height: 14),

            Text(
              bid.providerName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            if (bid.providerUsername.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '@${bid.providerUsername}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],

            const SizedBox(height: 22),

            Row(
              children: [
                Expanded(
                  child: _ProfileStat(
                    icon: Icons.star_rounded,
                    label: 'Rating',
                    value: bid.rating.toStringAsFixed(1),
                    color: Colors.amber.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ProfileStat(
                    icon: Icons.task_alt_rounded,
                    label: 'Jobs completed',
                    value: '${bid.totalJobsCompleted}',
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 10),

            _ProfileInformationRow(
              icon: Icons.payments_outlined,
              label: 'Bid amount',
              value: '৳${bid.price}',
            ),

            if (bid.estimatedArrival.isNotEmpty)
              _ProfileInformationRow(
                icon: Icons.access_time_outlined,
                label: 'Estimated arrival',
                value: bid.estimatedArrival,
              ),

            if (bid.message.isNotEmpty)
              _ProfileInformationRow(
                icon: Icons.message_outlined,
                label: 'Bid message',
                value: bid.message,
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
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
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(colors),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const Divider(height: 28),
          _InfoRow(
            icon: Icons.event_outlined,
            text: '${booking.scheduleDate}  ${booking.scheduleTime}'.trim(),
          ),
          if (location.isNotEmpty) ...[
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.location_on_outlined,
              text: location,
            ),
          ],
          if (booking.status.isNotEmpty) ...[
            const SizedBox(height: 12),
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
                  : colors.outlineVariant.withOpacity(0.45),
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
