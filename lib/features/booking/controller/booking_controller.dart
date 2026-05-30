import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../shared/widgets/success_model.dart';
import '../arguments/service_booking_arguments.dart';
import '../model/booking_request_model.dart';
import '../repository/booking_repository.dart';

class BookingController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final BookingRepository bookingRepository = BookingRepository();

  /// Service
  final serviceTitle = ''.obs;
  final servicePrice = 0.0.obs;
  final serviceImage = ''.obs;

  late final String serviceId;

  /// Step
  final currentStep = 1.obs;
  final isLoading = false.obs;

  /// Step 1
  final selectedSubServices = <String>[].obs;
  final problemDetailsController = TextEditingController();

  /// Step 2
  final dateController = TextEditingController();
  final addressController = TextEditingController();
  final budgetController = TextEditingController();

  RxnString selectedCity = RxnString();
  RxnString selectedTime = RxnString();

  /// Step 3
  final selectedPaymentMethod = 'bkash'.obs;

  final cities = [
    'Dhaka',
    'Chittagong',
    'Sylhet',
    'Rajshahi',
    'Khulna',
    'Barisal',
  ];

  final timeSlots = [
    '09:00 AM',
    '11:00 AM',
    '01:00 PM',
    '03:00 PM',
    '05:00 PM',
    '07:00 PM',
  ];

  final paymentMethods = [
    'bkash',
    'nagad',
    'card',
  ];

  late final List<String> subServiceOptions;

  static const _defaultSubs = [
    'Standard Service',
    'Premium Service',
    'Inspection',
    'Repair',
  ];

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as ServiceBookingArgument?;

    final service = args?.serviceDetails;

    if (service != null) {
      serviceId = service.id;
      serviceTitle.value = service.title;
      serviceImage.value = service.imageLink;
      servicePrice.value = (service.basePrice ?? 0).toDouble();
    }

    selectedCity.value = 'Dhaka';

    subServiceOptions = _defaultSubs;
  }

  @override
  void onClose() {
    problemDetailsController.dispose();
    dateController.dispose();
    addressController.dispose();
    budgetController.dispose();
    super.onClose();
  }

  void toggleSubService(String sub) {
    if (selectedSubServices.contains(sub)) {
      selectedSubServices.remove(sub);
    } else {
      selectedSubServices.add(sub);
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
    );

    if (picked != null) {
      dateController.text =
      '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';

      update();
    }
  }

  String? validateStep() {
    if (currentStep.value == 1) {
      if (problemDetailsController.text.trim().isEmpty) {
        return 'Please describe your problem.';
      }
    }

    if (currentStep.value == 2) {
      if (addressController.text.trim().isEmpty) {
        return 'Address is required.';
      }

      if (dateController.text.trim().isEmpty) {
        return 'Please pick a date.';
      }

      if (selectedTime.value == null ||
          selectedTime.value!.isEmpty) {
        return 'Please select a time slot.';
      }

      final budget =
          int.tryParse(budgetController.text.trim()) ?? 0;

      if (budget < 100) {
        return 'Set a budget of at least 100 BDT.';
      }
    }

    return null;
  }

  void nextStep(BuildContext context) {
    final error = validateStep();

    if (error != null) {
      Get.snackbar(
        'Validation',
        error,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade700,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
      );

      return;
    }

    if (currentStep.value < 3) {
      currentStep.value++;
    }
  }

  void prevStep() {
    if (currentStep.value > 1) {
      currentStep.value--;
    }
  }

  Future<void> submitBooking() async {
    try {
      isLoading.value = true;

      /// 1. CREATE BOOKING
      final request = BookingRequestModel(
        service: serviceId,
        details: problemDetailsController.text.trim(),
        subServices: selectedSubServices.toList(),
        location: LocationModel(
          address: addressController.text.trim(),
          city: selectedCity.value ?? 'Dhaka',
        ),
        schedule: ScheduleModel(
          date: dateController.text.trim(),
          time: selectedTime.value ?? '',
        ),
        maxLimit:
        int.tryParse(budgetController.text.trim()) ?? 0,
      );

      final createRes =
      await bookingRepository.createBooking(request);

      final success = createRes['success'] == true;

      if (!success) {
        throw Exception('Failed to create booking');
      }

      /// 2. GET BOOKING ID
      final bookingId =
      createRes['data']['_id'].toString();

      /// 3. CONFIRM PAYMENT
      await bookingRepository.confirmPayment(
        bookingId,
      );

      /// 4. SHOW SUCCESS MODAL
      await Get.dialog(
        SuccessModal(
          title: 'Booking Successful',
          message:
          'Your booking has been submitted successfully. Providers can now place bids on your request.',

          yesText: 'View My Bookings',

          onYes: () {
            Get.back();

            /// REDIRECT TO BOOKING LIST
            Get.offAllNamed(
              AppRoutes.myBookings,
            );
          },

          onClose: () {
            Get.back();

            /// REDIRECT TO BOOKING LIST
            Get.offAllNamed(
              AppRoutes.myBookings,
            );
          },
        ),

        barrierDismissible: false,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void cancel() => Get.back();
}