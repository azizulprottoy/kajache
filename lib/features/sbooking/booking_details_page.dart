import 'package:flutter/material.dart';
import '../../../app/theme/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/utils/media_url_helper.dart';
import '../../shared/shimmers/booking_details_shimmer.dart';
import '../../shared/widgets/common_app_bar.dart';
import '../../shared/widgets/custom_button.dart';
import '../../core/utils/translation_keys.dart';
import '../home/models/available_booking_response_model.dart';
import 'booking_details_controller.dart';
import '../tracking/live_tracking_map.dart';


class BookingDetailsPage extends GetView<BookingDetailsController> {
  const BookingDetailsPage({super.key});

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
          return const BookingDetailsShimmer();
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
              const SizedBox(height: 20),
              _ClientCard(poster: booking.poster),
              const SizedBox(height: 20),
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
                  ),
                ),

              // Reassignment offer — technician accept/decline
              if (booking.status == 'pending_reassignment') ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.assignment_late_outlined, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Text('Job Reassigned to You',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
                      ]),
                      const SizedBox(height: 6),
                      Text('Previous technician cancelled. Accept to take this job.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.orange.shade700)),
                      const SizedBox(height: 14),
                      Obx(() => Row(children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: controller.isRespondingReassignment.value
                                ? null
                                : () => controller.respondReassignment(accept: false),
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            child: const Text('Decline'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: controller.isRespondingReassignment.value
                                ? null
                                : () => controller.respondReassignment(accept: true),
                            style: FilledButton.styleFrom(backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            child: const Text('Accept Job'),
                          ),
                        ),
                      ])),
                    ],
                  ),
                ),
              ],

              // Technician cancel bid — only when bid_selected
              if (booking.status == 'bid_selected') ...[
                const SizedBox(height: 20),
                Obx(() => SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: controller.isCancellingBid.value
                        ? null
                        : () => _showCancelDialog(context),
                    icon: controller.isCancellingBid.value
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.cancel_outlined),
                    label: const Text('Cancel Bid'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                )),
              ],

              // Navigate to customer location map
              if (booking.locationLat != null &&
                  (booking.status == 'bidding_open' ||
                      booking.status == 'bid_selected' ||
                      booking.status == 'in_progress')) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TechnicianTrackingMap(
                          bookingId: booking.id,
                          customerLat: booking.locationLat!,
                          customerLng: booking.locationLng!,
                        ),
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Navigate to Customer'),
                  ),
                ),
              ],

              // Chat with customer (only once this bid has been selected)
              if (booking.myBidId != null &&
                  booking.myBidStatus?.trim().toLowerCase() == 'selected' &&
                  [
                    'bid_selected',
                    'in_progress',
                    'completed',
                  ].contains(booking.status.trim().toLowerCase())) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Get.toNamed(
                      AppRoutes.chatPage,
                      arguments: {
                        'bidId': booking.myBidId,
                        'bookingStatus': booking.status,
                      },
                    ),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Chat with Customer'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],

              // Mark cash received button (technician)
              if (booking.paymentMethod == 'cash' &&
                  !booking.cashReceived &&
                  (booking.status == 'completed' || booking.status == 'in_progress')) ...[
                const SizedBox(height: 20),
                Obx(() => SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: controller.isMarkingCash.value
                        ? null
                        : () => controller.markCashReceived(),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: controller.isMarkingCash.value
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.payments_outlined),
                    label: Text(TKeys.markCashReceived.tr),
                  ),
                )),
              ],

              if (booking.paymentMethod == 'cash' && booking.cashReceived) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(children: [
                    Icon(Icons.check_circle_rounded,
                        color: Colors.green.shade700),
                    const SizedBox(width: 10),
                    Text(TKeys.cashReceivedConfirmed.tr,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600)),
                  ]),
                ),
              ],
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        final booking = controller.booking.value;
        if (booking == null || booking.status != 'bidding_open') {
          return const SizedBox.shrink();
        }
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: CustomButton(
              label: booking.hasBid ? TKeys.editBid.tr : TKeys.bidNow.tr,
              isFullWidth: true,
              isLoading: controller.isBidLoading.value,
              onPressed: controller.isBidLoading.value
                  ? null
                  : () => _showBidSheet(context, booking),
            ),
          ),
        );
      }),
    );
  }

  void _showCancelDialog(BuildContext context) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Bid'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('⚠️ You will receive a strike and lose 20 reward points.',
              style: TextStyle(color: Colors.red, fontSize: 13)),
          const SizedBox(height: 12),
          TextField(
            controller: reasonCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Reason for cancellation (required)',
              border: OutlineInputBorder(),
            ),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Back')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              controller.cancelBid(reason: reasonCtrl.text.trim());
            },
            child: const Text('Confirm Cancel'),
          ),
        ],
      ),
    );
  }

  void _showBidSheet(
    BuildContext context,
    AvailableBookingModel booking,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BidSheet(
        isEditMode: booking.hasBid,
        initialPrice: booking.myBidPrice,
        initialEta: booking.myBidEstimatedArrival,
        initialMessage: booking.myBidMessage,
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

class _ClientCard extends StatelessWidget {
  final JobPosterModel poster;

  const _ClientCard({required this.poster});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final avatarUrl = MediaUrlHelper.resolve(poster.avatar);
    final profileLocation = [poster.address, poster.area, poster.district]
        .where((part) => part.trim().isNotEmpty)
        .join(', ');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(colors),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TKeys.postedBy.tr,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: colors.primaryContainer,
                backgroundImage:
                    avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                child: avatarUrl.isEmpty
                    ? Icon(Icons.person_outline, color: colors.primary)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      poster.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (profileLocation.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      _InfoRow(
                        icon: Icons.home_outlined,
                        text: profileLocation,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Stat(
                  icon: Icons.work_outline,
                  value: '${poster.jobPostCount}',
                  label: TKeys.jobsPosted.tr,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Stat(
                  icon: Icons.verified_user_outlined,
                  value: '${poster.trustScore}',
                  label: TKeys.trustScore.tr,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BidCard extends StatelessWidget {
  final BookingBidModel bid;
  final bool isMine;

  const _BidCard({required this.bid, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final avatarUrl = MediaUrlHelper.resolve(bid.providerAvatar);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isMine ? Colors.green.shade50 : colors.surfaceContainerLowest,
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
                radius: 21,
                backgroundImage:
                    avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                child: avatarUrl.isEmpty
                    ? const Icon(Icons.engineering_outlined)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isMine
                      ? '${bid.providerName} (${TKeys.myCurrentBid.tr})'
                      : bid.providerName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '৳${bid.price}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          if (bid.estimatedArrival.isNotEmpty) ...[
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.access_time_outlined,
              text: '${TKeys.estimatedArrival.tr}: ${bid.estimatedArrival}',
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

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withOpacity(.45),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
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
