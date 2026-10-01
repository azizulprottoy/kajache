import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/geo_repository.dart';
import '../../../app/routes/app_routes.dart';
import '../../main/controller/main_controller.dart';
import '../../../core/utils/app_services.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/success_model.dart';
import '../arguments/service_booking_arguments.dart';
import '../model/booking_request_model.dart';
import '../repository/booking_repository.dart';
import '../view/widgets/system_fee_payment_dialog.dart';

class BookingController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final BookingRepository bookingRepository = BookingRepository();

  /// Service
  final serviceTitle = ''.obs;
  final servicePrice = 0.0.obs;
  final serviceImage = ''.obs;
  final systemFee = 50.0.obs;

  /// Empty when the page was opened without a valid service argument.
  String serviceId = '';

  /// Single-page form, same fields as the website. The booking fee is paid
  /// after a bid is selected (see MyBookingDetailsController.confirmBookingPayment).
  final isLoading = false.obs;

  final selectedSubServices = <String>[].obs;
  final titleController = TextEditingController();
  final problemDetailsController = TextEditingController();

  /// Job photos, same limit as the website and the backend upload route
  static const int maxPhotos = 8;
  final photos = <File>[].obs;
  final ImagePicker _imagePicker = ImagePicker();

  /// District list for the dropdown; the map pin pre-selects a matching one
  final districts = <GeoModel>[].obs;
  final RxnString selectedDistrict = RxnString();

  final dateController = TextEditingController();
  final addressController = TextEditingController();

  // Map-picked location
  final RxnDouble pickedLat = RxnDouble();
  final RxnDouble pickedLng = RxnDouble();
  final RxnString pickedDistrict = RxnString();
  final RxnString pickedArea = RxnString();

  RxnString selectedTime = RxnString();

  final timeSlots = [
    '09:00 AM',
    '11:00 AM',
    '01:00 PM',
    '03:00 PM',
    '05:00 PM',
    '07:00 PM',
  ];


  final List<String> subServiceOptions = _defaultSubs;

  static const _defaultSubs = [
    'Standard Service',
    'Premium Service',
    'Inspection',
    'Repair',
  ];

  @override
  void onInit() {
    super.onInit();

    // Block technicians from booking flow
    final mainCtrl = Get.find<MainController>();
    if (mainCtrl.isServiceProvider) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
      });
      return;
    }

    final args = Get.arguments;
    final service =
        args is ServiceBookingArgument ? args.serviceDetails : null;

    if (service == null || service.id.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
        AppServices.showError('Could not open booking. Please select a service again.');
      });
      return;
    }

    serviceId = service.id;
    serviceTitle.value = service.title;
    serviceImage.value = service.image;
    servicePrice.value = service.basePrice;
    systemFee.value = service.systemFee;

    _loadDistricts();
  }

  Future<void> _loadDistricts() async {
    try {
      districts.assignAll(await GeoRepository().getDistricts());
    } catch (_) {
      // The dropdown stays empty; district is optional
    }
  }

  /// Picks the district from the map result when it matches one in the list.
  void applyPickedDistrict(String? name) {
    final picked = name?.trim().toLowerCase() ?? '';
    if (picked.isEmpty) return;
    for (final district in districts) {
      final candidate = district.name.toLowerCase();
      if (candidate == picked || picked.contains(candidate) || candidate.contains(picked)) {
        selectedDistrict.value = district.name;
        return;
      }
    }
  }

  Future<void> pickPhotos() async {
    final remaining = maxPhotos - photos.length;
    if (remaining <= 0) return;
    final picked = await _imagePicker.pickMultiImage(imageQuality: 85);
    photos.addAll(picked.take(remaining).map((file) => File(file.path)));
  }

  void removePhoto(int index) => photos.removeAt(index);

  @override
  void onClose() {
    titleController.dispose();
    problemDetailsController.dispose();
    dateController.dispose();
    addressController.dispose();
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

  /// First problem in the form, or null when it can be submitted.
  String? validateForm() {
    if (titleController.text.trim().isEmpty) {
      return TKeys.titleRequired.tr;
    }
    if (problemDetailsController.text.trim().isEmpty) {
      return TKeys.describeProblemError.tr;
    }
    if (addressController.text.trim().isEmpty) {
      return TKeys.addressRequired.tr;
    }
    if (dateController.text.trim().isEmpty) {
      return TKeys.pickDateError.tr;
    }
    if (selectedTime.value == null || selectedTime.value!.isEmpty) {
      return TKeys.selectTimeSlotError.tr;
    }
    return null;
  }

  void _showValidationError(String error) {
    Get.snackbar(
      TKeys.validation.tr,
      error,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade50,
      colorText: Colors.red.shade700,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
    );
  }

  /// `asDraft` saves without paying; the draft is published later from
  /// My Bookings by paying the bid placement fee.
  Future<void> submitBooking({bool asDraft = false}) async {
    if (serviceId.isEmpty) {
      AppServices.showError('No service selected.');
      return;
    }

    // Highlight every invalid field inline, then show the first problem
    formKey.currentState?.validate();
    final error = validateForm();
    if (error != null) {
      _showValidationError(error);
      return;
    }

    /// 1. PAY SYSTEM FEE — the backend only opens bidding once it is paid.
    /// The booking fee itself is still paid after a bid is selected.
    SystemFeePaymentResult? payment;
    if (!asDraft) {
      payment = await Get.dialog<SystemFeePaymentResult>(
        SystemFeePaymentDialog(systemFee: systemFee.value),
      );
      if (payment == null) return;
    }

    try {
      isLoading.value = true;

      /// 2. CREATE BOOKING with the system fee payment
      final request = BookingRequestModel(
        service: serviceId,
        title: titleController.text.trim(),
        isDraft: asDraft,
        photos: photos.toList(),
        details: problemDetailsController.text.trim(),
        subServices: selectedSubServices.toList(),
        location: LocationModel(
          address: addressController.text.trim(),
          lat: pickedLat.value,
          lng: pickedLng.value,
          district: selectedDistrict.value ?? pickedDistrict.value,
        ),
        schedule: ScheduleModel(
          date: dateController.text.trim(),
          time: selectedTime.value ?? '',
        ),
        paymentMethod: payment?.paymentMethod,
        transactionId: payment?.transactionId,
      );

      final createRes =
      await bookingRepository.createBooking(request);

      final success = createRes['success'] == true;

      if (!success) {
        throw Exception('Failed to create booking');
      }

      if (asDraft) {
        Get.until((r) => r.settings.name == AppRoutes.main);
        Get.toNamed(AppRoutes.myBookings);
        Get.snackbar(
          TKeys.success.tr,
          TKeys.draftSaved.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      /// 3. SHOW SUCCESS MODAL
      await Get.dialog(
        SuccessModal(
          title: TKeys.bookingSuccessful.tr,
          message:
          TKeys.bookingSubmittedMsg.tr,

          yesText: TKeys.viewMyBookings.tr,

          onYes: () {
            Get.back();

            /// REDIRECT TO BOOKING LIST
            Get.until((r) => r.settings.name == AppRoutes.main);
            Get.toNamed(AppRoutes.myBookings);
          },

          onClose: () {
            Get.back();

            /// REDIRECT TO BOOKING LIST
            Get.until((r) => r.settings.name == AppRoutes.main);
            Get.toNamed(AppRoutes.myBookings);
          },
        ),

        barrierDismissible: false,
      );
    } catch (e) {
      final data = e is DioException ? e.response?.data : null;
      final message = data is Map && data['message'] != null
          ? data['message'].toString()
          : 'Could not submit your booking. Please try again.';
      Get.snackbar(
        TKeys.error.tr,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade700,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void cancel() => Get.back();
}
