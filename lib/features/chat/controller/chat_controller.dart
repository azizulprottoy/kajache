import 'package:kaj_ache/core/utils/app_services.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/storage/local_storage_service.dart';
import '../model/chat_model.dart';
import '../repository/chat_repository.dart';

const _closedStatuses = ['completed', 'cancelled'];
const _pollInterval = Duration(seconds: 5);

class ChatController extends GetxController {
  final ChatRepository _repository = ChatRepository();
  final _localStorage = Get.find<LocalStorageService>();

  final messageController = TextEditingController();
  final RxList<BookingChatMessageModel> messages = <BookingChatMessageModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSending = false.obs;

  late final String bidId;
  late final String bookingStatus;
  String? _currentUserId;
  Timer? _pollTimer;
  bool _loading = false;

  bool get canSend => !_closedStatuses.contains(bookingStatus.trim().toLowerCase());

  bool isMine(BookingChatMessageModel message) =>
      _currentUserId != null && message.senderId == _currentUserId;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    bidId = args is Map ? (args['bidId']?.toString() ?? '') : '';
    bookingStatus = args is Map ? (args['bookingStatus']?.toString() ?? '') : '';

    if (bidId.isEmpty) {
      return;
    }

    _init();
  }

  void _init() {
    _currentUserId = _localStorage.read<String>('user_id');
    // Start the timer before the first await so onClose always cancels it.
    _pollTimer = Timer.periodic(_pollInterval, (_) {
      // Skip a poll while the previous request is still running.
      if (!_loading) _loadMessages(silent: true);
    });
    _loadMessages();
  }

  Future<void> _loadMessages({bool silent = false}) async {
    if (isClosed) return;
    _loading = true;
    if (!silent) isLoading.value = true;
    try {
      final result = await _repository.getMessages(bidId);
      if (!isClosed) messages.assignAll(result);
    } catch (_) {
      // Keep last known history on a failed poll.
    } finally {
      _loading = false;
      if (!silent && !isClosed) isLoading.value = false;
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || !canSend || isSending.value) return;

    isSending.value = true;
    try {
      messageController.clear();
      await _repository.sendMessage(bidId, text);
      await _loadMessages(silent: true);
    } catch (e) {
      // Put the text back so a failed send doesn't lose the message
      if (messageController.text.isEmpty) messageController.text = text;
      AppServices.showApiError(e);
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
