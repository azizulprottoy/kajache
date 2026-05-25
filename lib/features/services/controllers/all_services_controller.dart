import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../home/controllers/home_controller.dart';

class AllServicesController extends GetxController {
  RxBool isLoading = false.obs;
  final RxInt currentIndex = 0.obs;

  final RxList<ServiceModel> popularServices = <ServiceModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    AllServices();
  }

  Future<void> AllServices() async {
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(seconds: 1));
      popularServices.assignAll([
        ServiceModel(
          id: '1',
          title: 'pipe_leak_fix',
          category: 'plumbing',
          rating: 4.8,
          reviews: 120,
          price: 500,
          imageUrl: '',
        ),
        ServiceModel(
          id: '2',
          title: 'full_bathroom_clean',
          category: 'bathroom_cleaning',
          rating: 4.6,
          reviews: 98,
          price: 800,
          imageUrl: '',
        ),
        ServiceModel(
          id: '3',
          title: 'stove_burner_repair',
          category: 'stove_fixing',
          rating: 4.7,
          reviews: 75,
          price: 400,
          imageUrl: '',
        ),
        ServiceModel(
          id: '4',
          title: 'room_painting',
          category: 'painting',
          rating: 4.9,
          reviews: 210,
          price: 3000,
          imageUrl: '',
        ),
      ]);
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void onServiceTap(ServiceModel service) {
    // TODO: navigate to service detail page
  }

  @override
  void onClose() {
    super.onClose();
  }
}


