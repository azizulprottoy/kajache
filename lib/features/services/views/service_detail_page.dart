// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../../../app/routes/app_routes.dart';
// import '../../../core/utils/translation_keys.dart';
// import '../../../shared/widgets/common_app_bar.dart';
// import '../../../shared/widgets/custom_button.dart';
// import '../../../shared/widgets/success_model.dart';
// import '../../booking/controller/booking_controller.dart';
// import '../arguments/service_argument.dart';
// import '../controllers/services_details_controller.dart';
//
// class ServiceDetailPage extends GetView<ServicesDetailsController> {
//   const ServiceDetailPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     final args = Get.arguments as ServiceArgument?;
//     final isBooking = args?.isbooking ?? false;
//     final isProviderBidFlow = args?.isProviderBidFlow ?? false;
//     return Scaffold(
//       backgroundColor: colorScheme.surface,
//       appBar: const CommonAppBar(
//         title: 'service_details',
//         showLanguageToggle: true,
//         showBack: true,
//       ),
//       bottomNavigationBar: SafeArea(
//         top: false,
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//           child: isProviderBidFlow
//               ? CustomButton(
//             label: 'Bid Now',
//             variant: ButtonVariant.primary,
//             isFullWidth: true,
//             onPressed: () => _showBidingBottomSheet(context),
//           )
//               : isBooking
//               ? CustomButton(
//             label: 'View Provider Bids',
//             variant: ButtonVariant.primary,
//             isFullWidth: true,
//             onPressed: () => _showBidsBottomSheet(context),
//           )
//               : CustomButton(
//             label: 'Book Now',
//             variant: ButtonVariant.primary,
//             isFullWidth: true,
//             onPressed: () {
//               final service = controller.popularServices.first;
//
//               Get.toNamed(
//                 AppRoutes.bookingPage,
//                 arguments: BookingArgument(
//                   title: service.title.tr,
//                   category: service.category.tr,
//                   price: service.price,
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         if (controller.popularServices.isEmpty) {
//           return Center(
//             child: Text(
//               TKeys.noData.tr,
//               style: theme.textTheme.bodyLarge,
//             ),
//           );
//         }
//
//         final service = controller.popularServices.first;
//
//         return SingleChildScrollView(
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 height: 220,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(20),
//                   gradient: LinearGradient(
//                     colors: [
//                       colorScheme.primary,
//                       colorScheme.primary.withOpacity(0.75),
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//                 alignment: Alignment.center,
//                 child: Icon(
//                   Icons.home_repair_service_rounded,
//                   size: 72,
//                   color: colorScheme.onPrimary,
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//
//               Text(
//                 service.title.tr,
//                 style: theme.textTheme.headlineSmall?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: colorScheme.onSurface,
//                 ),
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 service.category.tr,
//                 style: theme.textTheme.titleMedium?.copyWith(
//                   color: colorScheme.onSurfaceVariant,
//                 ),
//               ),
//
//               const SizedBox(height: 14),
//
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 8,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.amber.withOpacity(0.12),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.star_rounded,
//                           size: 18,
//                           color: Colors.amber.shade700,
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           '${service.rating} (${service.reviews})',
//                           style: theme.textTheme.labelLarge?.copyWith(
//                             fontWeight: FontWeight.w600,
//                             color: colorScheme.onSurface,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Spacer(),
//                   Text(
//                     '৳${service.price.toInt()}',
//                     style: theme.textTheme.headlineSmall?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: colorScheme.primary,
//                     ),
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 24),
//
//               Text(
//                 'About Service',
//                 style: theme.textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: colorScheme.onSurface,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'This service request helps customers receive offers from multiple verified service providers. Review the request details and compare provider bids before proceeding.',
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   height: 1.6,
//                   color: colorScheme.onSurfaceVariant,
//                 ),
//               ),
//
//               const SizedBox(height: 24),
//
//               Text(
//                 'Request Details',
//                 style: theme.textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: colorScheme.onSurface,
//                 ),
//               ),
//               const SizedBox(height: 12),
//
//               _InfoCard(
//                 icon: Icons.calendar_today_outlined,
//                 title: 'Requested Date',
//                 value: '25 Apr 2026',
//               ),
//               const SizedBox(height: 10),
//               _InfoCard(
//                 icon: Icons.access_time_outlined,
//                 title: 'Preferred Time',
//                 value: '11:00 AM',
//               ),
//               const SizedBox(height: 10),
//               _InfoCard(
//                 icon: Icons.location_on_outlined,
//                 title: 'Service Address',
//                 value: 'House 12, Road 5, Dhanmondi, Dhaka',
//               ),
//
//               const SizedBox(height: 24),
//
//               Text(
//                 'What is included',
//                 style: theme.textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: colorScheme.onSurface,
//                 ),
//               ),
//               const SizedBox(height: 12),
//
//               _FeatureTile(
//                 text: 'Professional service provider',
//                 colorScheme: colorScheme,
//               ),
//               _FeatureTile(
//                 text: 'Quick response and support',
//                 colorScheme: colorScheme,
//               ),
//               _FeatureTile(
//                 text: 'Affordable pricing',
//                 colorScheme: colorScheme,
//               ),
//               _FeatureTile(
//                 text: 'Trusted and verified service',
//                 colorScheme: colorScheme,
//               ),
//             ],
//           ),
//         );
//       }),
//     );
//   }
//
//   void _showBidsBottomSheet(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//
//     final bids = [
//       _BidModel(
//         name: 'Rahim Electric Service',
//         rating: 4.8,
//         jobsDone: 136,
//         price: 850,
//         eta: 'Today, 11:30 AM',
//       ),
//       _BidModel(
//         name: 'FixFast Home Care',
//         rating: 4.6,
//         jobsDone: 98,
//         price: 780,
//         eta: 'Today, 12:00 PM',
//       ),
//       _BidModel(
//         name: 'Trusted Service BD',
//         rating: 4.9,
//         jobsDone: 210,
//         price: 920,
//         eta: 'Today, 10:45 AM',
//       ),
//     ];
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: colorScheme.surface,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       builder: (_) {
//         return SafeArea(
//           top: false,
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: 42,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: colorScheme.outlineVariant,
//                     borderRadius: BorderRadius.circular(99),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Service Provider Bids',
//                   style: theme.textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: colorScheme.onSurface,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   'Compare offers and choose the best provider for your request.',
//                   textAlign: TextAlign.center,
//                   style: theme.textTheme.bodySmall?.copyWith(
//                     color: colorScheme.onSurfaceVariant,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Flexible(
//                   child: ListView.separated(
//                     shrinkWrap: true,
//                     itemCount: bids.length,
//                     separatorBuilder: (_, __) => const SizedBox(height: 12),
//                     itemBuilder: (context, index) {
//                       final bid = bids[index];
//                       return Container(
//                         padding: const EdgeInsets.all(14),
//                         decoration: BoxDecoration(
//                           color: colorScheme.surface,
//                           borderRadius: BorderRadius.circular(18),
//                           border: Border.all(
//                             color: colorScheme.outlineVariant.withOpacity(0.25),
//                           ),
//                         ),
//                         child: Column(
//                           children: [
//                             Row(
//                               children: [
//                                 CircleAvatar(
//                                   radius: 24,
//                                   backgroundColor:
//                                   colorScheme.primary.withOpacity(0.1),
//                                   child: Icon(
//                                     Icons.person,
//                                     color: colorScheme.primary,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         bid.name,
//                                         style: theme.textTheme.titleSmall
//                                             ?.copyWith(
//                                           fontWeight: FontWeight.w700,
//                                           color: colorScheme.onSurface,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Text(
//                                         '${bid.jobsDone} jobs completed',
//                                         style:
//                                         theme.textTheme.bodySmall?.copyWith(
//                                           color: colorScheme.onSurfaceVariant,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Text(
//                                   '৳${bid.price}',
//                                   style:
//                                   theme.textTheme.titleMedium?.copyWith(
//                                     fontWeight: FontWeight.bold,
//                                     color: colorScheme.primary,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 12),
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.star_rounded,
//                                   size: 18,
//                                   color: Colors.amber.shade700,
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   '${bid.rating}',
//                                   style: theme.textTheme.bodyMedium?.copyWith(
//                                     fontWeight: FontWeight.w600,
//                                     color: colorScheme.onSurface,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 16),
//                                 Icon(
//                                   Icons.access_time_outlined,
//                                   size: 16,
//                                   color: colorScheme.onSurfaceVariant,
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Expanded(
//                                   child: Text(
//                                     bid.eta,
//                                     style: theme.textTheme.bodySmall?.copyWith(
//                                       color: colorScheme.onSurfaceVariant,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 14),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: OutlinedButton(
//                                     onPressed: () {},
//                                     child: const Text('View Profile'),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 10),
//                                 Expanded(
//                                   child: FilledButton(
//                                     onPressed: () {
//                                       Navigator.pop(context);
//                                     },
//                                     child: const Text('Accept Bid'),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   void _showBidingBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => const BiddingBottomSheet(),
//     );
//   }
// }
//
// class _InfoCard extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String value;
//
//   const _InfoCard({
//     required this.icon,
//     required this.title,
//     required this.value,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: colorScheme.surface,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(
//           color: colorScheme.outlineVariant.withOpacity(0.25),
//         ),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: colorScheme.primary),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: theme.textTheme.bodySmall?.copyWith(
//                     color: colorScheme.onSurfaceVariant,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   value,
//                   style: theme.textTheme.titleSmall?.copyWith(
//                     fontWeight: FontWeight.w600,
//                     color: colorScheme.onSurface,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _FeatureTile extends StatelessWidget {
//   final String text;
//   final ColorScheme colorScheme;
//
//   const _FeatureTile({
//     required this.text,
//     required this.colorScheme,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.symmetric(
//         horizontal: 14,
//         vertical: 14,
//       ),
//       decoration: BoxDecoration(
//         color: colorScheme.surface,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(
//           color: colorScheme.outlineVariant.withOpacity(0.25),
//         ),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             Icons.check_circle_rounded,
//             color: colorScheme.primary,
//             size: 22,
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               text,
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 color: colorScheme.onSurface,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _BidModel {
//   final String name;
//   final double rating;
//   final int jobsDone;
//   final int price;
//   final String eta;
//
//   _BidModel({
//     required this.name,
//     required this.rating,
//     required this.jobsDone,
//     required this.price,
//     required this.eta,
//   });
// }
//
//
// class BiddingBottomSheet extends StatefulWidget {
//   const BiddingBottomSheet({super.key});
//
//   @override
//   State<BiddingBottomSheet> createState() => _BiddingBottomSheetState();
// }
//
// class _BiddingBottomSheetState extends State<BiddingBottomSheet> {
//   final _formKey = GlobalKey<FormState>();
//   late final TextEditingController _priceController;
//   late final TextEditingController _etaController;
//   late final TextEditingController _noteController;
//
//   @override
//   void initState() {
//     super.initState();
//     _priceController = TextEditingController();
//     _etaController = TextEditingController();
//     _noteController = TextEditingController();
//   }
//
//   @override
//   void dispose() {
//     _priceController.dispose();
//     _etaController.dispose();
//     _noteController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _pickTime() async {
//     final picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//
//     if (picked != null && mounted) {
//       _etaController.text = picked.format(context);
//     }
//   }
//
//   void _submitBid() {
//     if (!_formKey.currentState!.validate()) return;
//
//     final price = _priceController.text.trim();
//     final eta = _etaController.text.trim();
//     final note = _noteController.text.trim();
//
//     Get.back();
//
//     Future.delayed(const Duration(milliseconds: 200), () {
//       showDialog(
//         context: context,
//         builder: (_) => SuccessModal(
//           title: 'Bid Submitted',
//           message: 'Your bid has been submitted successfully.',
//           yesText: 'OK',
//           onYes: () {
//             Get.back();
//           },
//           onClose: () {
//             Get.back();
//           },
//         ),
//       );
//     });
//
//     debugPrint('Bid price: $price');
//     debugPrint('ETA: $eta');
//     debugPrint('Note: $note');
//   }
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//
//     return SafeArea(
//       top: false,
//       child: DraggableScrollableSheet(
//         expand: false,
//         initialChildSize: 0.72,
//         minChildSize: 0.55,
//         maxChildSize: 0.92,
//         builder: (context, scrollController) {
//           return Container(
//             decoration: BoxDecoration(
//               color: colorScheme.surface,
//               borderRadius: const BorderRadius.vertical(
//                 top: Radius.circular(24),
//               ),
//             ),
//             child: SingleChildScrollView(
//               controller: scrollController,
//               padding: EdgeInsets.fromLTRB(
//                 16,
//                 12,
//                 16,
//                 MediaQuery.of(context).viewInsets.bottom + 16,
//               ),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       width: 42,
//                       height: 4,
//                       decoration: BoxDecoration(
//                         color: colorScheme.outlineVariant,
//                         borderRadius: BorderRadius.circular(99),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Place Your Bid',
//                       style: theme.textTheme.titleLarge?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         color: colorScheme.onSurface,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       'Submit your price and estimated arrival time for this service request.',
//                       textAlign: TextAlign.center,
//                       style: theme.textTheme.bodySmall?.copyWith(
//                         color: colorScheme.onSurfaceVariant,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//
//                     TextFormField(
//                       controller: _priceController,
//                       keyboardType: TextInputType.number,
//                       validator: (value) {
//                         if (value == null || value.trim().isEmpty) {
//                           return 'Please enter your bid price';
//                         }
//                         return null;
//                       },
//                       decoration: InputDecoration(
//                         labelText: 'Bid Price',
//                         hintText: 'Enter your price',
//                         prefixIcon: const Icon(Icons.currency_exchange),
//                         prefixText: '৳ ',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(14),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 14),
//
//                     TextFormField(
//                       controller: _etaController,
//                       readOnly: true,
//                       onTap: _pickTime,
//                       validator: (value) {
//                         if (value == null || value.trim().isEmpty) {
//                           return 'Please select estimated time';
//                         }
//                         return null;
//                       },
//                       decoration: InputDecoration(
//                         labelText: 'Estimated Arrival Time',
//                         hintText: 'Select time',
//                         prefixIcon: const Icon(Icons.access_time_outlined),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(14),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 14),
//
//                     TextFormField(
//                       controller: _noteController,
//                       maxLines: 4,
//                       decoration: InputDecoration(
//                         labelText: 'Note',
//                         hintText: 'Add a short message for the customer',
//                         alignLabelWithHint: true,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(14),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//
//                     Row(
//                       children: [
//                         Expanded(
//                           child: OutlinedButton(
//                             onPressed: () => Get.back(),
//                             style: OutlinedButton.styleFrom(
//                               minimumSize: const Size.fromHeight(50),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(14),
//                               ),
//                             ),
//                             child: const Text('Cancel'),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: FilledButton(
//                             onPressed: _submitBid,
//                             style: FilledButton.styleFrom(
//                               minimumSize: const Size.fromHeight(50),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(14),
//                               ),
//                             ),
//                             child: const Text('Submit Bid'),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }