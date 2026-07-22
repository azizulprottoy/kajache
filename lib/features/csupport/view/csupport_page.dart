import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../controller/csupport_controller.dart';

class CustomerSupportPage extends GetView<CustomerSupportController> {
  const CustomerSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CommonAppBar(
        title: TKeys.customerSupport.tr,
        showBack: true,
        showLanguageToggle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              TextFormField(
                controller: controller.subjectController,
                validator: (v) =>
                v == null || v.trim().isEmpty ? TKeys.subjectRequired.tr : null,
                decoration: InputDecoration(
                  labelText: TKeys.subject.tr,
                  prefixIcon: const Icon(Icons.subject_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: controller.messageController,
                maxLines: 6,
                validator: (v) =>
                v == null || v.trim().isEmpty ? TKeys.messageRequired.tr : null,
                decoration: InputDecoration(
                  labelText: TKeys.messageLabel.tr,
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 90),
                    child: Icon(Icons.message_outlined),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: controller.submitSupport,
                  child: Text(TKeys.submit.tr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}