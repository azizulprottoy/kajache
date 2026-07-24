import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../core/utils/media_url_helper.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/success_model.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../booking/arguments/service_booking_arguments.dart';
import '../../home/models/available_booking_response_model.dart';
import '../controller/service_details_controller.dart';

class ServiceDetailsPage extends GetView<ServiceDetailsController> {
  const ServiceDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isBooking = controller.isBooking;
    final isProviderBidFlow = controller.isProviderBidFlow;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CommonAppBar(
        title: TKeys.serviceDetails.tr,
        showLanguageToggle: true,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: isProviderBidFlow
              ? CustomButton(
            label: controller.hasBid
                ? TKeys.editBid.tr
                : TKeys.bidNow.tr,
            variant: ButtonVariant.primary,
            isFullWidth: true,
            onPressed: () => _showBidingBottomSheet(context),
          )
              : isBooking
              ? CustomButton(
            label: TKeys.viewProviderBids.tr,
            variant: ButtonVariant.primary,
            isFullWidth: true,
            onPressed: () => _showBidsBottomSheet(context),
          )
              : CustomButton(
            label: TKeys.bookNow.tr,
            variant: ButtonVariant.primary,
            isFullWidth: true,
            onPressed: () {
              final service = controller.service.value;
              if (service == null) return;

              Get.toNamed(
                AppRoutes.bookingPage,
                arguments: ServiceBookingArgument(serviceDetails: service),
              );
            },
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.service.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final service = controller.service.value;

        if (service == null) {
          return Center(
            child: Text(
              TKeys.serviceNotFound.tr,
              style: theme.textTheme.titleMedium,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchServiceDetails,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: service.imageLink.isNotEmpty
                    ? Image.network(
                  service.imageLink,
                  height: 190,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _ImageFallback(colorScheme: colorScheme),
                )
                    : _ImageFallback(colorScheme: colorScheme),
              ),

              const SizedBox(height: 20),

              Text(
                service.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                service.slug,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              if (isProviderBidFlow && controller.minLimit > 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.account_balance_wallet_outlined,
                          color: colorScheme.onPrimaryContainer),
                      const SizedBox(width: 10),
                      Text(
                        TKeys.customerBudget.tr,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '৳${controller.minLimit}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (isProviderBidFlow && controller.poster != null) ...[
                const SizedBox(height: 12),
                _PosterDetailsCard(poster: controller.poster!),
              ],

              if (isProviderBidFlow && controller.hasBid &&
                  controller.myBidPrice != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.how_to_reg_outlined,
                            color: Colors.green.shade700),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          TKeys.myCurrentBid.tr,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.green.shade800,
                          ),
                        ),
                      ),
                      Text(
                        '৳${controller.myBidPrice}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              service.description.isNotEmpty
                  ? Html(
                data: service.description,
                style: {
                  'body': Style(
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    fontSize: FontSize(
                        theme.textTheme.bodyMedium?.fontSize ?? 14),
                    color: colorScheme.onSurfaceVariant,
                    lineHeight: const LineHeight(1.5),
                  ),
                },
              )
                  : Text(
                TKeys.noDescription.tr,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Icon(
                    Icons.touch_app_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    TKeys.tapToStart.tr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }


  void _showBidingBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BiddingBottomSheet(
        isEditMode: controller.hasBid,
        initialPrice: controller.myBidPrice,
        initialEstimatedArrival: controller.myBidEstimatedArrival,
        initialMessage: controller.myBidMessage,
      ),
    );
  }

  void _showBidsBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    //
    // final bids = [
    //   _BidModel(
    //     name: 'Rahim Electric Service',
    //     rating: 4.8,
    //     jobsDone: 136,
    //     price: 850,
    //     eta: 'Today, 11:30 AM',
    //   ),
    //   _BidModel(
    //     name: 'FixFast Home Care',
    //     rating: 4.6,
    //     jobsDone: 98,
    //     price: 780,
    //     eta: 'Today, 12:00 PM',
    //   ),
    //   _BidModel(
    //     name: 'Trusted Service BD',
    //     rating: 4.9,
    //     jobsDone: 210,
    //     price: 920,
    //     eta: 'Today, 10:45 AM',
    //   ),
    // ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  TKeys.serviceProviderBids.tr,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  TKeys.compareOffers.tr,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),

                // Flexible(
                //   child: ListView.separated(
                //     shrinkWrap: true,
                //     itemCount: bids.length,
                //     separatorBuilder: (_, __) => const SizedBox(height: 12),
                //     itemBuilder: (context, index) {
                //       final bid = bids[index];
                //       return Container(
                //         padding: const EdgeInsets.all(14),
                //         decoration: BoxDecoration(
                //           color: colorScheme.surface,
                //           borderRadius: BorderRadius.circular(18),
                //           border: Border.all(
                //             color: colorScheme.outlineVariant.withOpacity(0.25),
                //           ),
                //         ),
                //         child: Column(
                //           children: [
                //             // Provider info row
                //             Row(
                //               children: [
                //                 CircleAvatar(
                //                   radius: 24,
                //                   backgroundColor:
                //                   colorScheme.primary.withOpacity(0.1),
                //                   child: Icon(
                //                     Icons.person,
                //                     color: colorScheme.primary,
                //                   ),
                //                 ),
                //                 const SizedBox(width: 12),
                //                 Expanded(
                //                   child: Column(
                //                     crossAxisAlignment:
                //                     CrossAxisAlignment.start,
                //                     children: [
                //                       Text(
                //                         bid.name,
                //                         style:
                //                         theme.textTheme.titleSmall?.copyWith(
                //                           fontWeight: FontWeight.w700,
                //                           color: colorScheme.onSurface,
                //                         ),
                //                       ),
                //                       const SizedBox(height: 4),
                //                       Text(
                //                         '${bid.jobsDone} jobs completed',
                //                         style:
                //                         theme.textTheme.bodySmall?.copyWith(
                //                           color: colorScheme.onSurfaceVariant,
                //                         ),
                //                       ),
                //                     ],
                //                   ),
                //                 ),
                //                 Text(
                //                   '৳${bid.price}',
                //                   style:
                //                   theme.textTheme.titleMedium?.copyWith(
                //                     fontWeight: FontWeight.bold,
                //                     color: colorScheme.primary,
                //                   ),
                //                 ),
                //               ],
                //             ),
                //
                //             const SizedBox(height: 12),
                //
                //             // Rating & ETA row
                //             Row(
                //               children: [
                //                 Icon(
                //                   Icons.star_rounded,
                //                   size: 18,
                //                   color: Colors.amber.shade700,
                //                 ),
                //                 const SizedBox(width: 4),
                //                 Text(
                //                   '${bid.rating}',
                //                   style: theme.textTheme.bodyMedium?.copyWith(
                //                     fontWeight: FontWeight.w600,
                //                     color: colorScheme.onSurface,
                //                   ),
                //                 ),
                //                 const SizedBox(width: 16),
                //                 Icon(
                //                   Icons.access_time_outlined,
                //                   size: 16,
                //                   color: colorScheme.onSurfaceVariant,
                //                 ),
                //                 const SizedBox(width: 4),
                //                 Expanded(
                //                   child: Text(
                //                     bid.eta,
                //                     style: theme.textTheme.bodySmall?.copyWith(
                //                       color: colorScheme.onSurfaceVariant,
                //                     ),
                //                   ),
                //                 ),
                //               ],
                //             ),
                //
                //             const SizedBox(height: 14),
                //
                //             // Action buttons
                //             Row(
                //               children: [
                //                 Expanded(
                //                   child: OutlinedButton(
                //                     onPressed: () {},
                //                     child: const Text('View Profile'),
                //                   ),
                //                 ),
                //                 const SizedBox(width: 10),
                //                 Expanded(
                //                   child: FilledButton(
                //                     onPressed: () => Navigator.pop(context),
                //                     child: const Text('Accept Bid'),
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ],
                //         ),
                //       );
                //     },
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PosterDetailsCard extends StatelessWidget {
  final JobPosterModel poster;

  const _PosterDetailsCard({required this.poster});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final avatarUrl = MediaUrlHelper.resolve(poster.avatar);
    final location = poster.location;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TKeys.postedBy.tr,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: colorScheme.primaryContainer,
                backgroundImage:
                avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                child: avatarUrl.isEmpty
                    ? Icon(
                  Icons.person_outline,
                  color: colorScheme.onPrimaryContainer,
                )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      poster.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (location.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 15,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
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
                child: _PosterStat(
                  icon: Icons.work_outline,
                  value: '${poster.jobPostCount}',
                  label: TKeys.jobsPosted.tr,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PosterStat(
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

class _PosterStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _PosterStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.45),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
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

// ── Image fallback ─────────────────────────────────────────────────────────
class _ImageFallback extends StatelessWidget {
  final ColorScheme colorScheme;

  const _ImageFallback({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.category_outlined,
        size: 56,
        color: colorScheme.primary,
      ),
    );
  }
}

// ── Bidding bottom sheet ───────────────────────────────────────────────────
class BiddingBottomSheet extends StatefulWidget {
  final bool isEditMode;
  final int? initialPrice;
  final String? initialEstimatedArrival;
  final String? initialMessage;

  const BiddingBottomSheet({
    super.key,
    this.isEditMode = false,
    this.initialPrice,
    this.initialEstimatedArrival,
    this.initialMessage,
  });

  @override
  State<BiddingBottomSheet> createState() => _BiddingBottomSheetState();
}

class _BiddingBottomSheetState extends State<BiddingBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _priceController;
  late final TextEditingController _etaController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.initialPrice != null ? '${widget.initialPrice}' : '',
    );
    _etaController = TextEditingController(
      text: widget.initialEstimatedArrival ?? '',
    );
    _noteController = TextEditingController(
      text: widget.initialMessage ?? '',
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _etaController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      _etaController.text = picked.format(context);
    }
  }

  Future<void> _submitBid() async {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceController.text.trim());
    final eta = _etaController.text.trim();
    final note = _noteController.text.trim();

    if (price == null) return;

    final controller = Get.find<ServiceDetailsController>();
    final success = await controller.submitBid(
      price: price,
      estimatedArrival: eta,
      message: note,
    );

    if (!success) return;

    Get.back();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (Get.context != null) {
        showDialog(
          context: Get.context!,
          builder: (_) => SuccessModal(
            title: widget.isEditMode
                ? TKeys.bidUpdated.tr
                : TKeys.bidSubmitted.tr,
            message: widget.isEditMode
                ? TKeys.bidUpdatedMsg.tr
                : TKeys.bidSubmittedMsg.tr,
            yesText: TKeys.ok.tr,
            onYes: () => Get.back(),
            onClose: () => Get.back(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      top: false,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        minChildSize: 0.55,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.outlineVariant,
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
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      TKeys.placeBidSubtitle.tr,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Bid price field
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return TKeys.enterBidPriceError.tr;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: TKeys.bidPrice.tr,
                        hintText: TKeys.enterPrice.tr,
                        prefixIcon: const Icon(Icons.currency_exchange),
                        prefixText: '৳ ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ETA field
                    TextFormField(
                      controller: _etaController,
                      readOnly: true,
                      onTap: _pickTime,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return TKeys.selectEstimatedTimeError.tr;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: TKeys.estimatedArrival.tr,
                        hintText: TKeys.selectTime.tr,
                        prefixIcon: const Icon(Icons.access_time_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Note field
                    TextFormField(
                      controller: _noteController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: TKeys.note.tr,
                        hintText: TKeys.noteHint.tr,
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Cancel / Submit buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(TKeys.cancel.tr),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(() {
                            final loading = Get.find<ServiceDetailsController>()
                                .isBidLoading
                                .value;
                            return FilledButton(
                              onPressed: loading ? null : _submitBid,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: loading
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white),
                              )
                                  : Text(widget.isEditMode
                                  ? TKeys.updateBid.tr
                                  : TKeys.submitBid.tr),
                            );
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
