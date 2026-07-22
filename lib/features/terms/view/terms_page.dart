import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../../../core/utils/translation_keys.dart';
import '../controller/terms_controller.dart';

class TermsConditionPage extends GetView<TermsConditionController> {
  const TermsConditionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CommonAppBar(
        title: TKeys.termsConditions.tr,
        showBack: true,
        showLanguageToggle: true,
      ),
      body: Obx(
            () => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Text(
            controller.content.value,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.7,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}