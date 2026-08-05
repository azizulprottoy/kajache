import 'package:flutter/material.dart';
import '../../../app/theme/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../../../shared/shimmers/shome_shimmer.dart';
import '../../sbooking/booking_details_arguments.dart';
import '../controllers/shome_controller.dart';
import '../models/available_booking_response_model.dart';

class SHomePage extends GetView<SHomeController> {
  const SHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CommonAppBar(
        title: 'app_name',
        showLanguageToggle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.availableBookings.isEmpty) {
          return const ShomeShimmer();
        }

        return RefreshIndicator(
          onRefresh: controller.fetchDashboardData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withOpacity(0.75),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${TKeys.welcomeBack.tr}!',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onPrimary.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        TKeys.dashboardSubtitle.tr,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  TKeys.todayOverview.tr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _OverviewCard(
                        title: TKeys.availableJobs.tr,
                        value: '${controller.newOrders.value}',
                        icon: Icons.receipt_long_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _OverviewCard(
                        title: TKeys.ongoing.tr,
                        value: '${controller.ongoing.value}',
                        icon: Icons.pending_actions_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _OverviewCard(
                        title: TKeys.completed.tr,
                        value: '${controller.completed.value}',
                        icon: Icons.check_circle_outline,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _OverviewCard(
                        title: TKeys.earnings.tr,
                        value: controller.earnings.value,
                        icon: Icons.account_balance_wallet_outlined,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Instant Services ──────────────────────────────────────
                _SectionHeader(
                  title: TKeys.availableInstantServices.tr,
                  icon: Icons.bolt_outlined,
                  onSeeAll: () => Get.toNamed(AppRoutes.availableInstantServices),
                  theme: theme,
                  colorScheme: colorScheme,
                ),
                const SizedBox(height: 10),
                if (controller.instantServices.isEmpty)
                  _EmptyState(message: 'No instant service requests right now.')
                else
                  ...controller.instantServices.take(3).map((item) =>
                    _QuickJobTile(
                      title: item.title,
                      subtitle: '৳${item.priceMin}–৳${item.priceMax}',
                      icon: Icons.bolt_outlined,
                      onTap: () => Get.toNamed(AppRoutes.availableInstantServices),
                      colorScheme: colorScheme,
                      theme: theme,
                    ),
                  ),

                const SizedBox(height: 24),

                // ── Recruitment Requests ──────────────────────────────────
                _SectionHeader(
                  title: TKeys.availableRecruitmentRequests.tr,
                  icon: Icons.badge_outlined,
                  onSeeAll: () => Get.toNamed(AppRoutes.availableRecruitmentRequests),
                  theme: theme,
                  colorScheme: colorScheme,
                ),
                const SizedBox(height: 10),
                if (controller.recruitmentRequests.isEmpty)
                  _EmptyState(message: 'No recruitment posts right now.')
                else
                  ...controller.recruitmentRequests.take(3).map((item) =>
                    _QuickJobTile(
                      title: item.title,
                      subtitle: '৳${item.salary.toInt()} • ${item.category}',
                      icon: Icons.badge_outlined,
                      onTap: () => Get.toNamed(AppRoutes.availableRecruitmentRequests),
                      colorScheme: colorScheme,
                      theme: theme,
                    ),
                  ),

                const SizedBox(height: 24),

                Text(
                  TKeys.availableJobs.tr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

                if (controller.availableBookings.isEmpty)
                  _EmptyState(
                    message: TKeys.noAvailableJobs.tr,
                  )
                else
                  ...controller.availableBookings.map(
                        (item) => GestureDetector(
                      onTap: () async {
                        debugPrint('[SHome] booking id=${item.id} slug=${item.serviceSlug}');
                        await Get.toNamed(
                          AppRoutes.bookingDetails,
                          arguments: BookingDetailsArgument(
                            bookingId: item.id,
                          ),
                        );
                        await controller.fetchDashboardData();
                      },
                      child: _BookedServiceTile(booking: item),
                    ),
                  ),

              ],
            ),
          ),
        );
      }),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookedServiceTile extends StatelessWidget {
  final AvailableBookingModel booking;

  const _BookedServiceTile({
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final alreadyBid = booking.hasBid;

    final cardColor = alreadyBid
        ? Colors.green.shade50
        : colorScheme.surface;
    final borderColor = alreadyBid
        ? Colors.green.shade300
        : colorScheme.borderColor;
    final iconBg = alreadyBid
        ? Colors.green.withOpacity(0.12)
        : colorScheme.primary.withOpacity(0.1);
    final iconColor = alreadyBid ? Colors.green.shade700 : colorScheme.primary;

    final statusColor = booking.hasBids ? Colors.blue : Colors.orange;
    final statusLabel = booking.hasBids
        ? '${booking.bidsCount} ${TKeys.bids.tr}'
        : TKeys.noBidsYet.tr;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.home_repair_service_outlined,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.serviceTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${TKeys.customer.tr}: ${booking.clientName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    booking.budgetLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  if (alreadyBid && booking.myBidPrice != null)
                    Text(
                      'My bid: ৳${booking.myBidPrice}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 15,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                booking.scheduleDate,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.access_time_outlined,
                size: 15,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                booking.scheduleTime,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              if (alreadyBid)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    TKeys.bidPlaced.tr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ActivityTile({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.miscellaneous_services_outlined,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onSeeAll;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _SectionHeader({
    required this.title, required this.icon,
    required this.onSeeAll, required this.theme, required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 18, color: colorScheme.primary),
      const SizedBox(width: 8),
      Expanded(child: Text(title, style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold, color: colorScheme.onSurface))),
      TextButton(
        onPressed: onSeeAll,
        child: Text(TKeys.seeAll.tr,
            style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.primary)),
      ),
    ]);
  }
}

class _QuickJobTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _QuickJobTile({
    required this.title, required this.subtitle, required this.icon,
    required this.onTap, required this.colorScheme, required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorScheme.borderColor),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: colorScheme.onPrimaryContainer, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant)),
            ],
          )),
          Icon(Icons.chevron_right_rounded, color: colorScheme.onSurfaceVariant, size: 18),
        ]),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.borderColor,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 40,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            message,
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
