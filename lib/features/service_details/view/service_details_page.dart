import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/success_model.dart';
import '../../booking/arguments/service_booking_arguments.dart';
import '../../booking/controller/booking_controller.dart';
import '../arguments/service_details_arguments.dart';
import '../controller/service_details_controller.dart';

// class _BidModel {
//   final String name;
//   final double rating;
//   final int jobsDone;
//   final int price;
//   final String eta;
//
//   const _BidModel({
//     required this.name,
//     required this.rating,
//     required this.jobsDone,
//     required this.price,
//     required this.eta,
//   });
// }

class ServiceDetailsPage extends GetView<ServiceDetailsController> {
  const ServiceDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final args = Get.arguments as ServiceDetailsArgument;
    final isBooking = args?.isbooking ?? false;
    final isProviderBidFlow = args?.isProviderBidFlow ?? false;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CommonAppBar(
        title: 'Service Details',
        showLanguageToggle: true,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: isProviderBidFlow
              ? CustomButton(
            label: 'Bid Now',
            variant: ButtonVariant.primary,
            isFullWidth: true,
            onPressed: () => _showBidingBottomSheet(context),
          )
              : isBooking
              ? CustomButton(
            label: 'View Provider Bids',
            variant: ButtonVariant.primary,
            isFullWidth: true,
            onPressed: () => _showBidsBottomSheet(context),
          )
              : CustomButton(
            label: 'Book Now',
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
              'Service not found',
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

              const SizedBox(height: 16),

              Text(
                service.description.isNotEmpty
                    ? service.description
                    : 'No description available',
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
                    'Tap the button below to get started',
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
      builder: (_) => const BiddingBottomSheet(),
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
                  'Service Provider Bids',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Compare offers and choose the best provider for your request.',
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
  const BiddingBottomSheet({super.key});

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
    _priceController = TextEditingController();
    _etaController = TextEditingController();
    _noteController = TextEditingController();
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

  void _submitBid() {
    if (!_formKey.currentState!.validate()) return;

    // Capture values before closing the sheet
    final price = _priceController.text.trim();
    final eta = _etaController.text.trim();
    final note = _noteController.text.trim();

    debugPrint('Bid price: $price');
    debugPrint('ETA: $eta');
    debugPrint('Note: $note');

    // Close the bottom sheet first
    Get.back();

    // Then show the success dialog using the navigator context
    Future.delayed(const Duration(milliseconds: 200), () {
      if (Get.context != null) {
        showDialog(
          context: Get.context!,
          builder: (_) => SuccessModal(
            title: 'Bid Submitted',
            message: 'Your bid has been submitted successfully.',
            yesText: 'OK',
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
                      'Place Your Bid',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Submit your price and estimated arrival time for this service request.',
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
                          return 'Please enter your bid price';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Bid Price',
                        hintText: 'Enter your price',
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
                          return 'Please select estimated time';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Estimated Arrival Time',
                        hintText: 'Select time',
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
                        labelText: 'Note',
                        hintText: 'Add a short message for the customer',
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
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: _submitBid,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text('Submit Bid'),
                          ),
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