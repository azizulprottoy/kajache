import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/media_url_helper.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../controller/my_instant_service_details_controller.dart';
import '../model/instant_service_model.dart';

/// The customer's single instant-service details page — view bids, select
/// bidder, pay platform fee, mark complete, cancel.
///
/// Mirrors `lib/features/my_bookings/view/my_booking_details_page.dart`
/// closely, renamed to InstantService's own fields (title/details/
/// priceMin-priceMax instead of service/minLimit, platformFee instead of
/// bookingFee, no schedule requirement).
class MyInstantServiceDetailsPage extends GetView<MyInstantServiceDetailsController> {
  const MyInstantServiceDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CommonAppBar(
        title: TKeys.instantServiceDetailsTitle.tr,
        showLanguageToggle: true,
      ),
      body: Obx(() {
        final item = controller.instantService.value;
        if (controller.isLoading.value && item == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (item == null) {
          return _ErrorState(onRetry: controller.fetchInstantService);
        }

        return RefreshIndicator(
          onRefresh: controller.fetchInstantService,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _JobCard(item: item),

              if (controller.isPaymentDue) ...[
                const SizedBox(height: 14),
                _PaymentDueBanner(controller: controller),
              ],

              if (item.status.trim().toLowerCase() == 'bidding_open') ...[
                const SizedBox(height: 14),
                Obx(() => SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: controller.isCancelling.value
                            ? null
                            : () async {
                                final reason = await _promptReason(
                                  context,
                                  TKeys.cancelInstantService.tr,
                                  'Why are you cancelling?',
                                );
                                if (reason == null) return;
                                await controller.cancelInstantService(reason: reason);
                              },
                        icon: controller.isCancelling.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.cancel_outlined),
                        label: Text(TKeys.cancelInstantService.tr),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.error,
                          side: BorderSide(color: colorScheme.error),
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    )),
              ],

              if (item.status.trim().toLowerCase() == 'in_progress') ...[
                const SizedBox(height: 14),
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: controller.isCompletingTask.value
                          ? null
                          : () async {
                              final confirmed = await _confirmTaskCompletion(context);
                              if (!confirmed) return;

                              final success = await controller.completeInstantService();
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
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.task_alt_rounded),
                      label: Text(
                        controller.isCompletingTask.value ? 'Completing...' : TKeys.markTaskComplete.tr,
                      ),
                    ),
                  ),
                ),
              ],

              _SectionTitle(
                icon: Icons.gavel_outlined,
                title: 'Submitted bids',
                count: item.bids.length,
              ),
              const SizedBox(height: 10),

              if (item.bids.isEmpty)
                const _EmptyBids()
              else
                ...item.bids.map(
                  (bid) => _BidCard(
                    bid: bid,
                    isMine: bid.id == item.myBid?.id,
                    onTap: () {
                      controller.viewBidder(bid);
                      Get.bottomSheet(
                        _BidderProfileSheet(bid: bid, controller: controller),
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
        content: const Text('Confirm that the technician has finished this job.'),
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
  final MyInstantServiceDetailsController controller;

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
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'You selected a technician for this job. Pay the platform fee to let them start.',
            style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Get.bottomSheet(
                _InstantServicePaymentSheet(controller: controller),
                isScrollControlled: true,
                isDismissible: false,
                enableDrag: false,
                backgroundColor: Colors.transparent,
              ),
              icon: const Icon(Icons.payment_outlined),
              label: Text(TKeys.payNow.tr),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstantServicePaymentSheet extends StatefulWidget {
  final MyInstantServiceDetailsController controller;

  const _InstantServicePaymentSheet({required this.controller});

  @override
  State<_InstantServicePaymentSheet> createState() => _InstantServicePaymentSheetState();
}

class _InstantServicePaymentSheetState extends State<_InstantServicePaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _transactionIdController = TextEditingController();

  @override
  void dispose() {
    _transactionIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await widget.controller.confirmInstantServicePayment(
      transactionId: _transactionIdController.text,
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
    final fee = controller.platformFee;
    final bidPrice = controller.selectedBid?.price ?? 0;
    final total = fee + bidPrice;

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
                    TKeys.payConfirm.tr,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'A technician has been selected. Pay the platform fee + bid amount to confirm.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                TKeys.platformFee.tr,
                                style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                              ),
                            ),
                            Text('৳$fee', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                TKeys.jobBudget.tr,
                                style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                              ),
                            ),
                            Text('৳$bidPrice',
                                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                TKeys.totalAmount.tr,
                                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              '৳$total',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      TKeys.paymentMethod.tr,
                      style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
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
                        final isSelected = controller.selectedPaymentMethod.value?.id == m.id;
                        final desc = m.description.isNotEmpty ? m.description : m.account;
                        return GestureDetector(
                          onTap: () => controller.selectedPaymentMethod.value = m,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? colors.primary.withValues(alpha: 0.06) : colors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? colors.primary : colors.outlineVariant,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: m.image.isNotEmpty
                                      ? Image.network(
                                          m.image,
                                          width: 36,
                                          height: 36,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) => _PaymentIcon(colors: colors),
                                        )
                                      : _PaymentIcon(colors: colors),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        m.name,
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: isSelected ? colors.primary : colors.onSurface,
                                        ),
                                      ),
                                      if (desc.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          desc,
                                          style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check_circle_rounded, color: colors.primary, size: 20),
                              ],
                            ),
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
                    validator: (v) => v == null || v.trim().isEmpty ? TKeys.transactionIdRequired.tr : null,
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
                            : Text('${TKeys.payNow.tr} ৳$total'),
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
        child: Icon(Icons.payment_outlined, color: colors.onPrimaryContainer, size: 20),
      );
}

class _BidderProfileSheet extends StatelessWidget {
  final InstantServiceBidModel bid;
  final MyInstantServiceDetailsController controller;

  const _BidderProfileSheet({required this.bid, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final avatarUrl = MediaUrlHelper.resolve(bid.provider.avatar);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
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
              backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
              child: avatarUrl.isEmpty
                  ? Icon(Icons.engineering_outlined, size: 44, color: colors.onPrimaryContainer)
                  : null,
            ),
            const SizedBox(height: 14),

            Text(
              bid.provider.name,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (bid.provider.username.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '@${bid.provider.username}',
                style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],

            const SizedBox(height: 22),

            Row(
              children: [
                Expanded(
                  child: _ProfileStat(
                    icon: Icons.star_rounded,
                    label: 'Rating',
                    value: bid.provider.rating.toStringAsFixed(1),
                    color: Colors.amber.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ProfileStat(
                    icon: Icons.task_alt_rounded,
                    label: 'Jobs completed',
                    value: '${bid.provider.totalJobsCompleted}',
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
              final status = controller.instantService.value?.status.trim().toLowerCase() ?? '';
              final canSelect = status == 'bidding_open';

              if (!canSelect) return const SizedBox.shrink();

              return SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: controller.isSelectingBid.value
                      ? null
                      : () async {
                          final success = await controller.selectBid(bid);
                          if (!success) return;

                          if (Get.isBottomSheetOpen ?? false) Get.back();

                          Get.snackbar(
                            TKeys.success.tr,
                            'Bidder selected. Pay the platform fee to let them start.',
                            snackPosition: SnackPosition.BOTTOM,
                          );

                          Get.bottomSheet(
                            _InstantServicePaymentSheet(controller: controller),
                            isScrollControlled: true,
                            isDismissible: false,
                            enableDrag: false,
                            backgroundColor: Colors.transparent,
                          );
                        },
                  icon: controller.isSelectingBid.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(controller.isSelectingBid.value ? 'Selecting...' : TKeys.selectBidder.tr),
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

class _ProfileInformationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInformationRow({required this.icon, required this.label, required this.value});

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
            child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final InstantServiceDetailsModel item;

  const _JobCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final imageUrl = MediaUrlHelper.resolve(item.image);
    final location = [item.location.address, item.location.district.isNotEmpty ? item.location.district : item.location.city]
        .where((part) => part.trim().isNotEmpty)
        .join(', ');

    return Container(
      padding: const EdgeInsets.all(16),
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
                        errorBuilder: (_, __, ___) => _ServiceIcon(colors: colors),
                      )
                    : _ServiceIcon(colors: colors),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title.isEmpty ? TKeys.untitledService.tr : item.title,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.priceRangeLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            item.details.trim().isEmpty ? TKeys.noDescription.tr : item.details,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
          const Divider(height: 28),
          if (location.isNotEmpty) ...[
            _InfoRow(icon: Icons.location_on_outlined, text: location),
            const SizedBox(height: 12),
          ],
          if (!item.schedule.isEmpty) ...[
            _InfoRow(icon: Icons.event_outlined, text: '${item.schedule.date}  ${item.schedule.time}'.trim()),
            const SizedBox(height: 12),
          ],
          _InfoRow(icon: Icons.pending_actions_outlined, text: item.status.replaceAll('_', ' ')),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final int? count;

  const _SectionTitle({required this.icon, required this.title, this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
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
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class _BidCard extends StatelessWidget {
  final InstantServiceBidModel bid;
  final bool isMine;
  final VoidCallback onTap;

  const _BidCard({required this.bid, required this.isMine, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final avatarUrl = MediaUrlHelper.resolve(bid.provider.avatar);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isMine ? Colors.green.shade50 : colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isMine ? Colors.green.shade300 : colors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 23,
                    backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl.isEmpty ? const Icon(Icons.engineering_outlined) : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bid.provider.name,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Tap to view profile',
                          style: theme.textTheme.bodySmall?.copyWith(color: colors.primary),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '৳${bid.price}',
                    style: theme.textTheme.titleMedium?.copyWith(color: colors.primary, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
                ],
              ),
              if (bid.estimatedArrival.isNotEmpty) ...[
                const SizedBox(height: 10),
                _InfoRow(icon: Icons.access_time_outlined, text: 'Estimated arrival: ${bid.estimatedArrival}'),
              ],
              if (bid.message.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(bid.message, style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
              ],
            ],
          ),
        ),
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
      child: Icon(Icons.bolt_outlined, color: colors.onPrimaryContainer),
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
          FilledButton(onPressed: onRetry, child: Text(TKeys.retry.tr)),
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
