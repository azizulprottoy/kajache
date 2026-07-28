import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/translation_keys.dart';
import '../model/csupport_model.dart';
import '../repository/csupport_repository.dart';

class CustomerSupportController extends GetxController {
  final CsupportRepository _repository = Get.find<CsupportRepository>();

  final formKey = GlobalKey<FormState>();
  final subjectController = TextEditingController();
  final messageController = TextEditingController();

  final RxBool isSubmitting = false.obs;
  final RxBool isLoadingFaqs = false.obs;
  final RxList<FaqModel> faqs = <FaqModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadFaqs();
  }

  Future<void> _loadFaqs() async {
    isLoadingFaqs.value = true;
    try {
      faqs.assignAll(await _repository.getFaqs());
    } catch (_) {
    } finally {
      if (!isClosed) isLoadingFaqs.value = false;
    }
  }

  Future<void> submitSupport() async {
    if (!formKey.currentState!.validate()) return;

    isSubmitting.value = true;
    try {
      await _repository.submitTicket(
        title: subjectController.text.trim(),
        reason: messageController.text.trim(),
      );
      subjectController.clear();
      messageController.clear();
      Get.snackbar(
        TKeys.supportSubmitted.tr,
        TKeys.supportSubmittedMsg.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        TKeys.error.tr,
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (!isClosed) isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    subjectController.dispose();
    messageController.dispose();
    super.onClose();
  }
}
