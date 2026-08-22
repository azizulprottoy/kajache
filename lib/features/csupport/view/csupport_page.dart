import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../app/theme/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controller/local_controller.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../controller/csupport_controller.dart';
import '../model/csupport_model.dart';

class CustomerSupportPage extends GetView<CustomerSupportController> {
  const CustomerSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localeController = Get.find<LocaleController>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CommonAppBar(
        title: TKeys.customerSupport.tr,
        showBack: true,
        showLanguageToggle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Submit form ────────────────────────────────────────────────
            Form(
              key: controller.formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: controller.subjectController,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? TKeys.subjectRequired.tr
                        : null,
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
                    validator: (v) => v == null || v.trim().isEmpty
                        ? TKeys.messageRequired.tr
                        : null,
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
                  const SizedBox(height: 20),
                  Obx(() => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: controller.isSubmitting.value
                          ? null
                          : controller.submitSupport,
                      child: controller.isSubmitting.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(TKeys.submit.tr),
                    ),
                  )),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── FAQ section ────────────────────────────────────────────────
            Text(
              TKeys.frequentlyAskedQuestions.tr,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),

            Obx(() {
              if (controller.isLoadingFaqs.value) {
                return const _FaqShimmer();
              }

              if (controller.faqs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      TKeys.noFaqsAvailable.tr,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: controller.faqs
                    .map((faq) => _FaqTile(
                          faq: faq,
                          isBengali: localeController.isBengali,
                        ))
                    .toList(),
              );
            }),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── FAQ expandable tile ───────────────────────────────────────────────────────
class _FaqTile extends StatelessWidget {
  final FaqModel faq;
  final bool isBengali;

  const _FaqTile({required this.faq, required this.isBengali});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.borderColor,
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        shape: const Border(),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.help_outline_rounded,
              size: 25, color: colorScheme.onPrimaryContainer),
        ),
        title: Text(
          faq.localizedQuestion(isBengali),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        children: [
          Html(
            data:  faq.localizedAnswer(isBengali),
            style: {
              'body': Style(
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                fontSize: FontSize(
                    theme.textTheme.bodyMedium?.fontSize ?? 14),
                color: colorScheme.onSurface,
                lineHeight: const LineHeight(1.2),
              ),
            },
          )

        ],
      ),
    );
  }
}

class _FaqShimmer extends StatelessWidget {
  const _FaqShimmer();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: List.generate(
        4,
        (_) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          height: 58,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorScheme.borderColor,
            ),
          ),
        ),
      ),
    );
  }
}
