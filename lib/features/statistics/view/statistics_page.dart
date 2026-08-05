import 'package:flutter/material.dart';
import '../../../app/theme/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/translation_keys.dart';
import '../../../shared/shimmers/statistics_shimmer.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../../../app/routes/app_routes.dart';
import '../../home/models/available_booking_response_model.dart';
import '../../sbooking/booking_details_arguments.dart';
import '../controller/statistics_controller.dart';

class StatisticsPage extends GetView<StatisticsController> {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CommonAppBar(
        title: TKeys.statistics.tr,
        showLanguageToggle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.acceptedBookings.isEmpty) {
          return const StatisticsShimmer();
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.acceptedBookings.isEmpty) {
          return _ErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.fetchAcceptedBookings,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchAcceptedBookings,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Text(
                'Accepted Bookings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Bookings where your bid was accepted, including jobs already in progress.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 18),
              if (controller.acceptedBookings.isEmpty)
                const _EmptyState()
              else
                ...controller.acceptedBookings.map(
                  (booking) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: GestureDetector(
                      onTap: () => Get.toNamed(
                        AppRoutes.bookingDetails,
                        arguments: BookingDetailsArgument(bookingId: booking.bookingId),
                      ),
                      child: _AcceptedBookingCard(
                        booking: booking,
                        controller: controller,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _AcceptedBookingCard extends StatelessWidget {
  final ProviderBidModel booking;
  final StatisticsController controller;

  const _AcceptedBookingCard({
    required this.booking,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final schedule = [
      booking.scheduleDate,
      booking.scheduleTime,
    ].where((value) => value.trim().isNotEmpty).join(' • ');
    final isInProgress = controller.isInProgress(booking);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
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
                child: Icon(
                  Icons.handyman_outlined,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.serviceTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Booking #${_shortId(booking.bookingId)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isInProgress
                      ? colorScheme.tertiary.withValues(alpha: 0.12)
                      : colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isInProgress ? 'In Progress' : 'Accepted',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isInProgress
                        ? colorScheme.tertiary
                        : colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (schedule.isNotEmpty) ...[
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              text: schedule,
            ),
          ],
          if (booking.price != null) ...[
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.payments_outlined,
              text: 'Your bid: ৳${booking.price}',
            ),
          ],
          if (booking.estimatedArrival.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.schedule_outlined,
              text: 'Estimated arrival: ${booking.estimatedArrival}',
            ),
          ],
          const SizedBox(height: 18),
          if (controller.canMakeInProgress(booking))
            SizedBox(
              width: double.infinity,
              child: Obx(() {
                final processing =
                    controller.isProcessing(booking.bookingId);

                return FilledButton.icon(
                  onPressed: processing
                      ? null
                      : () => controller.confirmMakeInProgress(booking),
                  icon: processing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.play_arrow_rounded),
                  label: Text(
                    processing ? 'Starting...' : 'Make In Progress',
                  ),
                );
              }),
            )
          else if (isInProgress)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.tertiary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                'Job is currently in progress',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.tertiary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _shortId(String id) {
    if (id.length <= 8) return id;
    return id.substring(id.length - 8).toUpperCase();
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 72),
      child: Column(
        children: [
          Icon(
            Icons.assignment_turned_in_outlined,
            size: 64,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No accepted or in-progress bookings',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Accepted bids and active jobs will appear here.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 54),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: Text(TKeys.tryAgain.tr),
            ),
          ],
        ),
      ),
    );
  }
}
