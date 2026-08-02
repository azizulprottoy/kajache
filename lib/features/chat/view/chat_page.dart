import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../controller/chat_controller.dart';

class ChatPage extends GetView<ChatController> {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CommonAppBar(
        title: TKeys.chat.tr,
        showBack: true,
        showLanguageToggle: true,
      ),
      body: Column(
        children: [
          if (!controller.canSend)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: colorScheme.surfaceContainerHighest,
              child: Row(
                children: [
                  Icon(Icons.lock_outline_rounded, size: 16, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This chat is closed: the booking is already finished.',
                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.messages.isEmpty) {
                return Center(
                  child: Text(
                    'No messages yet. Say hello!',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final msg = controller.messages[index];
                  final isMine = controller.isMine(msg);

                  return Align(
                    alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isMine
                            ? colorScheme.primary
                            : colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        msg.content,
                        style: TextStyle(
                          color: isMine
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          if (controller.canSend)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.messageController,
                        decoration: InputDecoration(
                          hintText: TKeys.typeMessage.tr,
                          filled: true,
                          fillColor: colorScheme.surfaceContainerLowest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Obx(() => IconButton.filled(
                          onPressed: controller.isSending.value ? null : controller.sendMessage,
                          icon: const Icon(Icons.send),
                        )),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
