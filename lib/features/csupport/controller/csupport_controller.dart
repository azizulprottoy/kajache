import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerSupportController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final subjectController = TextEditingController();
  final messageController = TextEditingController();

  void submitSupport() {
    if (!formKey.currentState!.validate()) return;

    Get.snackbar(
      'Success',
      'Support request submitted successfully',
      snackPosition: SnackPosition.BOTTOM,
    );

    subjectController.clear();
    messageController.clear();
  }

  @override
  void onClose() {
    subjectController.dispose();
    messageController.dispose();
    super.onClose();
  }
}