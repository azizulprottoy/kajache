import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/worker_profile_model.dart';


class ProfileController extends GetxController {
  final Rx<ProfileType> profileType = ProfileType.buyer.obs;

  final formKey = GlobalKey<FormState>();

  // Common fields
  late TextEditingController fullNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  // Service provider fields
  late TextEditingController businessNameController;
  late TextEditingController categoryController;
  late TextEditingController experienceController;
  late TextEditingController serviceAreaController;

  final RxBool isLoading = false.obs;

  bool get isBuyer => profileType.value == ProfileType.buyer;
  bool get isServiceProvider => profileType.value == ProfileType.serviceProvider;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args is ProfileType) {
      profileType.value = args;
    }

    fullNameController = TextEditingController(text: 'Prottoy Alam');
    emailController = TextEditingController(text: 'prottoy@example.com');
    phoneController = TextEditingController(text: '+8801XXXXXXXXX');
    addressController = TextEditingController(text: 'Dhaka, Bangladesh');

    businessNameController =
        TextEditingController(text: 'Rahim Electric Service');
    categoryController = TextEditingController(text: 'Electrician');
    experienceController = TextEditingController(text: '5 Years');
    serviceAreaController = TextEditingController(text: 'Dhaka City');
  }

  void saveProfile() {
    if (!formKey.currentState!.validate()) return;

    Get.snackbar(
      'Success',
      'Profile saved successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void updateProfile() {
    if (!formKey.currentState!.validate()) return;

    Get.snackbar(
      'Success',
      'Profile updated successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    businessNameController.dispose();
    categoryController.dispose();
    experienceController.dispose();
    serviceAreaController.dispose();
    super.onClose();
  }
}