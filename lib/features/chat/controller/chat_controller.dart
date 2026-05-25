import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  final messageController = TextEditingController();
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;

  @override
  void onInit() {
    super.onInit();
    messages.assignAll([
      ChatMessage(
        text: 'Hello, are you available tomorrow morning?',
        isMe: false,
      ),
      ChatMessage(
        text: 'Yes, I am available after 10 AM.',
        isMe: true,
      ),
      ChatMessage(
        text: 'Great, please come by 11 AM.',
        isMe: false,
      ),
    ]);
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    messages.add(ChatMessage(text: text, isMe: true));
    messageController.clear();
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}

class ChatMessage {
  final String text;
  final bool isMe;

  ChatMessage({
    required this.text,
    required this.isMe,
  });
}