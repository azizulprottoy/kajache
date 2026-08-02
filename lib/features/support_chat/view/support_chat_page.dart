import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../controller/support_chat_controller.dart';

class SupportChatPage extends GetView<SupportChatController> {
  const SupportChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CommonAppBar(
        title: TKeys.supportChat.tr,
        showBack: true,
        showLanguageToggle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.messages.isEmpty) {
                return Center(
                  child: Text(
                    'No messages yet. Send us a message and our team will reply here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final msg = controller.messages[index];

                  return Align(
                    alignment: msg.isMine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: msg.isMine
                            ? colorScheme.primary
                            : colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        msg.message,
                        style: TextStyle(
                          color: msg.isMine
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
