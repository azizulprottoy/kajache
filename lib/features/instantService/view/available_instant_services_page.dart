import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';

import '../../../core/utils/money_format.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/booking_status_helper.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../../../shared/widgets/job_feedback_sheets.dart';
import '../controller/available_instant_services_controller.dart';
import '../model/instant_service_model.dart';

/// Technician-side: browse open instant services and place a bid. Once the
/// customer has selected this technician's bid AND paid the platform fee,
/// an "Accept Job" button appears to lock the job in progress.
///
/// Mirrors the tap-to-view-then-bid pattern used for the technician
/// "available bookings" feed (`lib/features/home/views/shome_page.dart` +
/// `lib/features/sbooking/booking_details_page.dart`), collapsed into a
/// single page since there is no separate locked route for instant-service
/// details on the technician side.
///
/// Fetches the job, then opens its details sheet. Ignores taps while a sheet
/// is already opening.
Future<void> _openInstantServiceSheet(AvailableInstantServicesController controller, String id) async {
  if (id.isEmpty || controller.isOpeningSheet) return;
  controller.isOpeningSheet = true;
  try {
    await controller.openInstantService(id);
    if (controller.selectedItem.value?.id != id) return;
    await Get.bottomSheet(
      _InstantServiceDetailsSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  } finally {
    controller.isOpeningSheet = false;
  }
}

class AvailableInstantServicesPage extends GetView<AvailableInstantServicesController> {
  const AvailableInstantServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // A specific job was passed in (home tile / notification): open it once
    final initialId = controller.takeInitialId();
    if (initialId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openInstantServiceSheet(controller, initialId));
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CommonAppBar(
        title: TKeys.availableInstantServices.tr,
        showLanguageToggle: true,
      ),
      body: Obx(() {
        final jobs = controller.myJobs;
        final open = controller.instantServices;

        if (controller.isLoading.value && open.isEmpty && jobs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        Future<void> openDetails(InstantServiceModel item) => _openInstantServiceSheet(controller, item.id);

        return RefreshIndicator(
          onRefresh: controller.fetchAvailableInstantServices,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              if (controller.isLoadingDetails.value) ...[
                const LinearProgressIndicator(),
                const SizedBox(height: 12),
              ],
              // Jobs this technician was selected for; "Accept Job" lives in the details sheet
              if (jobs.isNotEmpty) ...[
                Text(
                  TKeys.myInstantJobs.tr,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  TKeys.myInstantJobsSubtitle.tr,
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                for (final job in jobs) ...[
                  GestureDetector(
                    onTap: () => openDetails(job),
                    child: _InstantServiceTile(item: job),
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 12),
                Text(
                  TKeys.availableInstantServices.tr,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
              ],
              if (open.isEmpty) ...[
                SizedBox(height: MediaQuery.sizeOf(context).height * (jobs.isEmpty ? 0.3 : 0.05)),
                Icon(Icons.bolt_outlined, size: 64, color: colorScheme.outline),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    TKeys.noAvailableJobs.tr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ] else
                for (final item in open) ...[
                  GestureDetector(
                    onTap: () => openDetails(item),
                    child: _InstantServiceTile(item: item),
                  ),
                  const SizedBox(height: 12),
                ],
            ],
          ),
        );
      }),
    );
  }
}

class _InstantServiceTile extends StatelessWidget {
  final InstantServiceModel item;

  const _InstantServiceTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final alreadyBid = item.hasBid;

    final cardColor = alreadyBid ? Colors.green.shade50 : colorScheme.surface;
    final borderColor = alreadyBid ? Colors.green.shade300 : colorScheme.outlineVariant;
    final iconBg = alreadyBid ? Colors.green.withOpacity(0.12) : colorScheme.primary.withOpacity(0.1);
    final iconColor = alreadyBid ? Colors.green.shade700 : colorScheme.primary;
    final statusColor = item.bidsCount > 0 ? Colors.blue : Colors.orange;
    final statusLabel = item.bidsCount > 0 ? '${item.bidsCount} ${TKeys.bids.tr}' : TKeys.noBidsYet.tr;
    final statusInfo = BookingStatusHelper.of(item.status);

    return Container(
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
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.bolt_outlined, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title.isEmpty ? TKeys.untitledService.tr : item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [if (item.category.isNotEmpty) item.category, item.locationLabel]
                          .where((v) => v.trim().isNotEmpty)
                          .join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 110),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item.priceRangeLabel,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                      ),
                      if (alreadyBid && item.myBid != null)
                        Text(
                          '${TKeys.myBid.tr}: ${formatTaka(item.myBid!.price)}',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.green.shade700, fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.pending_actions_outlined, size: 15, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  statusInfo.label,
                  style: theme.textTheme.bodySmall?.copyWith(color: statusInfo.color, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              if (alreadyBid)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    item.myBid != null && item.myBid!.status != 'active'
                        ? BookingStatusHelper.bid(item.myBid!.status).label
                        : TKeys.bidPlaced.tr,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.green.shade700, fontWeight: FontWeight.w600),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    statusLabel,
                    style: theme.textTheme.bodySmall?.copyWith(color: statusColor, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InstantServiceDetailsSheet extends StatelessWidget {
  final AvailableInstantServicesController controller;

  const _InstantServiceDetailsSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Obx(() {
          if (controller.isLoadingDetails.value && controller.selectedItem.value == null) {
            return const SizedBox(
              height: 160,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final item = controller.selectedItem.value;
          if (item == null) {
            return SizedBox(height: 120, child: Center(child: Text(TKeys.serviceNotFound.tr)));
          }

          final statusInfo = BookingStatusHelper.of(item.status);
          final myBid = item.myBid;
          final canBid = item.status.trim().toLowerCase() == 'bidding_open';
          final status = item.status.trim().toLowerCase();
          final myBidStatus = myBid?.status.trim().toLowerCase() ?? '';
          final isSelectedForMe = myBidStatus == 'selected';
          final canAccept = isSelectedForMe &&
              status == 'bid_selected' &&
              item.paymentStatus.trim().toLowerCase() == 'paid';

          // What the technician should know right now about this job
          Widget? notice;
          if (status == 'cancelled') {
            final reason = item.cancellationReason?.trim() ?? '';
            notice = JobStatusNotice(
              icon: Icons.cancel_outlined,
              color: Colors.red.shade700,
              title: TKeys.jobCancelledTitle.tr,
              message: reason.isEmpty ? TKeys.noReasonGiven.tr : '${TKeys.cancellationReasonLabel.tr}: $reason',
            );
          } else if (myBidStatus == 'rejected') {
            notice = JobStatusNotice(
              icon: Icons.info_outline,
              color: Colors.grey.shade700,
              message: TKeys.bidNotSelectedMsg.tr,
            );
          } else if (isSelectedForMe && status == 'in_progress') {
            notice = JobStatusNotice(
              icon: Icons.construction_rounded,
              color: Colors.blue.shade700,
              message: TKeys.inProgressTechnicianMsg.tr,
            );
          } else if (isSelectedForMe && status == 'completed') {
            notice = JobStatusNotice(
              icon: Icons.task_alt_rounded,
              color: Colors.green.shade700,
              message: TKeys.jobCompletedTechnicianMsg.tr,
            );
          } else if (isSelectedForMe && status == 'bid_selected' && !canAccept) {
            notice = JobStatusNotice(
              icon: Icons.hourglass_top_rounded,
              color: Colors.orange.shade700,
              message: TKeys.selectedWaitingPaymentMsg.tr,
            );
          }

          return SingleChildScrollView(
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title.isEmpty ? TKeys.untitledService.tr : item.title,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusInfo.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        statusInfo.label,
                        style: theme.textTheme.labelSmall?.copyWith(color: statusInfo.color, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (item.details.trim().isEmpty)
                  Text(TKeys.noDescription.tr, style: theme.textTheme.bodyMedium?.copyWith(height: 1.4))
                else
                  Html(
                    data: item.details,
                    style: {
                      'body': Style(
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                        color: colors.onSurface,
                        fontSize: FontSize(theme.textTheme.bodyMedium?.fontSize ?? 14),
                        lineHeight: const LineHeight(1.4),
                      ),
                    },
                  ),
                const SizedBox(height: 14),
                _DetailRow(icon: Icons.payments_outlined, label: TKeys.jobBudget.tr, value: item.priceRangeLabel),
                if (item.category.isNotEmpty)
                  _DetailRow(icon: Icons.category_outlined, label: TKeys.category.tr, value: item.category),
                if (item.locationLabel.isNotEmpty)
                  _DetailRow(
                    icon: Icons.location_on_outlined,
                    label: TKeys.address.tr,
                    value: item.locationLabel,
                  ),
                if (!item.schedule.isEmpty)
                  _DetailRow(
                    icon: Icons.event_outlined,
                    label: TKeys.dateLabel.tr,
                    value: '${item.schedule.date} ${item.schedule.time}'.trim(),
                  ),

                const SizedBox(height: 18),

                if (myBid != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.primary.withOpacity(0.25)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          TKeys.myCurrentBid.tr,
                          style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(formatTaka(myBid.price), style: theme.textTheme.titleMedium?.copyWith(color: colors.primary, fontWeight: FontWeight.w800)),
                        if (myBid.estimatedArrival.isNotEmpty)
                          Text('${TKeys.estimatedArrival.tr}: ${myBid.estimatedArrival}', style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
                        const SizedBox(height: 4),
                        Text(
                          BookingStatusHelper.bid(myBid.status).label,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: BookingStatusHelper.bid(myBid.status).color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                if (notice != null) ...[
                  notice,
                  const SizedBox(height: 14),
                ],

                if (canAccept) ...[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: controller.isAccepting.value
                          ? null
                          : () async {
                              final success = await controller.acceptJob();
                              if (!success) return;
                              if (Get.isBottomSheetOpen ?? false) Get.back();
                              Get.snackbar(
                                TKeys.success.tr,
                                TKeys.jobAcceptedMsg.tr,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            },
                      icon: controller.isAccepting.value
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.task_alt_rounded),
                      label: Text(controller.isAccepting.value ? TKeys.accepting.tr : TKeys.acceptJob.tr),
                    ),
                  ),
                ] else if (canBid && (myBid == null || myBidStatus == 'active')) ...[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => Get.bottomSheet(
                        _InstantServiceBidSheet(
                          controller: controller,
                          isEditMode: myBid != null,
                          initialPrice: myBid?.price,
                          initialEta: myBid?.estimatedArrival,
                          initialMessage: myBid?.message,
                          priceMin: item.priceMin,
                          priceMax: item.priceMax,
                        ),
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                      ),
                      icon: Icon(myBid != null ? Icons.edit_outlined : Icons.gavel_outlined),
                      label: Text(myBid != null ? TKeys.editBid.tr : TKeys.bidNow.tr),
                    ),
                  ),
                ],

                // Selected technicians can raise a dispute about the job
                if (isSelectedForMe || myBidStatus == 'cancelled') ...[
                  const SizedBox(height: 10),
                  JobFeedbackActions(
                    onReport: () => Get.bottomSheet(
                      JobComplaintSheet(
                        isSubmitting: controller.isSubmittingComplaint,
                        onSubmit: (title, reason) => controller.submitComplaint(title: title, reason: reason),
                      ),
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: colors.primary),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _InstantServiceBidSheet extends StatefulWidget {
  final AvailableInstantServicesController controller;
  final bool isEditMode;
  final int? initialPrice;
  final String? initialEta;
  final String? initialMessage;
  final int priceMin;
  final int priceMax;

  const _InstantServiceBidSheet({
    required this.controller,
    required this.isEditMode,
    this.initialPrice,
    this.initialEta,
    this.initialMessage,
    required this.priceMin,
    required this.priceMax,
  });

  @override
  State<_InstantServiceBidSheet> createState() => _InstantServiceBidSheetState();
}

/// Arrival estimates offered to technicians. The English value is what the
/// API stores (same wording as the website); the key is its label.
const Map<String, String> _arrivalOptions = {
  '15 mins': TKeys.eta15Mins,
  '30 mins': TKeys.eta30Mins,
  '45 mins': TKeys.eta45Mins,
  '1 hour': TKeys.eta1Hour,
  '2 hours': TKeys.eta2Hours,
  '3 hours': TKeys.eta3Hours,
  'Same day': TKeys.etaSameDay,
  'Next day': TKeys.etaNextDay,
};

class _InstantServiceBidSheetState extends State<_InstantServiceBidSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _price;
  late final TextEditingController _message;
  String? _eta;

  @override
  void initState() {
    super.initState();
    _price = TextEditingController(text: widget.initialPrice?.toString() ?? '');
    _message = TextEditingController(text: widget.initialMessage ?? '');
    final initialEta = widget.initialEta?.trim() ?? '';
    _eta = initialEta.isNotEmpty ? initialEta : '30 mins';
  }

  @override
  void dispose() {
    _price.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.controller.isBidLoading.value) return;
    if (!_formKey.currentState!.validate()) return;

    final success = await widget.controller.submitBid(
      price: int.parse(_price.text.trim()),
      estimatedArrival: _eta?.trim() ?? '',
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
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                    decoration: BoxDecoration(color: colors.outlineVariant, borderRadius: BorderRadius.circular(99)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.isEditMode ? TKeys.editYourBid.tr : TKeys.placeYourBid.tr,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    TKeys.bidPriceRangeMsg.trParams({
                      'min': formatTaka(widget.priceMin),
                      'max': formatTaka(widget.priceMax),
                    }),
                    style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _price,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final amount = int.tryParse(value?.trim() ?? '');
                      if (amount == null || amount <= 0) return TKeys.enterBidPriceError.tr;
                      if (amount < widget.priceMin || amount > widget.priceMax) {
                        return TKeys.bidPriceRangeMsg.trParams({
                          'min': formatTaka(widget.priceMin),
                          'max': formatTaka(widget.priceMax),
                        });
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: TKeys.bidPrice.tr,
                      prefixText: '৳ ',
                      prefixIcon: const Icon(Icons.currency_exchange),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _eta,
                    isExpanded: true,
                    items: [
                      // Keep an older free-text estimate selectable when editing
                      if (_eta != null && !_arrivalOptions.containsKey(_eta))
                        DropdownMenuItem(value: _eta, child: Text(_eta!, maxLines: 1, overflow: TextOverflow.ellipsis)),
                      for (final entry in _arrivalOptions.entries)
                        DropdownMenuItem(value: entry.key, child: Text(entry.value.tr)),
                    ],
                    onChanged: (value) => setState(() => _eta = value),
                    validator: (value) => value == null || value.trim().isEmpty ? TKeys.selectEstimatedTimeError.tr : null,
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
                    maxLength: 500,
                    decoration: InputDecoration(
                      labelText: TKeys.note.tr,
                      hintText: TKeys.noteHint.tr,
                      alignLabelWithHint: true,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Obx(() {
                    final loading = widget.controller.isBidLoading.value;
                    return Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: loading ? null : () => Navigator.of(context).pop(),
                            child: Text(TKeys.cancel.tr),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: loading ? null : _submit,
                            child: loading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : Text(widget.isEditMode ? TKeys.updateBid.tr : TKeys.submitBid.tr),
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
