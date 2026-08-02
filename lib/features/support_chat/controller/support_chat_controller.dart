import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/support_chat_model.dart';
import '../repository/support_chat_repository.dart';

const _pollInterval = Duration(seconds: 5);

class SupportChatController extends GetxController {
  final SupportChatRepository _repository = SupportChatRepository();

  final messageController = TextEditingController();
  final RxList<SupportChatMessageModel> messages = <SupportChatMessageModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSending = false.obs;

  Timer? _pollTimer;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    await _loadThread();
    unawaited(_repository.markRead());
    _pollTimer = Timer.periodic(_pollInterval, (_) => _loadThread(silent: true));
  }

  Future<void> _loadThread({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    try {
      final result = await _repository.getThread();
      messages.assignAll(result);
    } catch (_) {
      // Keep last known history on a failed poll.
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || isSending.value) return;

    isSending.value = true;
    try {
      messageController.clear();
      await _repository.sendMessage(text);
      await _loadThread(silent: true);
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSending.value = false;
    }
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    messageController.dispose();
    super.onClose();
  }
}
