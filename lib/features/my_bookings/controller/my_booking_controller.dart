import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/my_booking_model.dart';
import '../../../core/utils/translation_keys.dart';
import '../repository/my_booking_repository.dart';

class MyBookingController extends GetxController {
  final MyBookingRepository repository = MyBookingRepository();

  final isLoading = false.obs;

  final bookings = <MyBookingModel>[].obs;

  @override
  void onInit() {
    super.onInit();

    fetchBookings();
  }

  Future<void> fetchBookings() async {
    try {
      isLoading.value = true;

      final result = await repository.getMyBookings();

      bookings.assignAll(result);
    } catch (e) {
      Get.snackbar(TKeys.error.tr, e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
