import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';

import '../../../app/theme/context_extension.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../controller/recruitment_request_controller.dart';

class RecruitmentRequestPage extends GetView<RecruitmentRequestController> {
  const RecruitmentRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CommonAppBar(
        title: TKeys.postRecruitmentRequest.tr,
        showLanguageToggle: true,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Obx(() => FilledButton.icon(
                onPressed: controller.isLoading.value ? null : controller.submitRequest,
                icon: controller.isLoading.value
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.work_outline_rounded, size: 18),
                label: Text(
                  controller.isLoading.value ? TKeys.loading.tr : TKeys.payNow.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              )),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Cover image ──────────────────────────────────────────────
              Obx(() => _CoverImagePicker(
                    image: controller.pickedImage.value,
                    onTap: controller.pickCoverImage,
                  )),

              const SizedBox(height: 20),

              // ── Job details card ─────────────────────────────────────────
              _SectionCard(
                colorScheme: colorScheme,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      icon: Icons.badge_outlined,
                      label: 'Job Details',
                      colorScheme: colorScheme,
                      theme: theme,
                    ),
                    const SizedBox(height: 16),

                    _FieldLabel('Job Title', theme),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: controller.titleController,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Please enter a job title' : null,
                      decoration: InputDecoration(
                        hintText: 'e.g. Full-time AC Technician',
                        prefixIcon: const Icon(Icons.title_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _FieldLabel(TKeys.recruitmentDetailsLabel.tr, theme),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: colorScheme.outlineVariant),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: HtmlEditor(
                          controller: controller.detailsEditorController,
                          htmlEditorOptions: HtmlEditorOptions(
                            hint: TKeys.recruitmentDetailsHint.tr,
                            shouldEnsureVisible: true,
                          ),
                          htmlToolbarOptions: const HtmlToolbarOptions(
                            defaultToolbarButtons: [
                              FontButtons(
                                bold: true,
                                italic: true,
                                underline: true,
                                clearAll: false,
                                strikethrough: false,
                                superscript: false,
                                subscript: false,
                              ),
                              ListButtons(listStyles: false),
                            ],
                          ),
                          otherOptions: const OtherOptions(height: 220),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(TKeys.durationLabel.tr, theme),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: controller.durationController,
                                validator: (v) =>
                                    v == null || v.trim().isEmpty ? TKeys.durationHint.tr : null,
                                decoration: InputDecoration(
                                  hintText: TKeys.durationHint.tr,
                                  prefixIcon: const Icon(Icons.schedule_outlined),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(TKeys.salaryLabel.tr, theme),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: controller.salaryController,
                                keyboardType: TextInputType.number,
                                onChanged: (v) =>
                                    controller.salaryValue.value =
                                        double.tryParse(v.trim()) ?? 0,
                                validator: (v) {
                                  final n = num.tryParse(v?.trim() ?? '');
                                  if (n == null || n <= 0) return 'Enter a valid salary';
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: TKeys.salaryHint.tr,
                                  prefixIcon: const Icon(Icons.payments_outlined),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Payment card ─────────────────────────────────────────────
              _SectionCard(
                colorScheme: colorScheme,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      icon: Icons.payments_outlined,
                      label: TKeys.payToPost.tr,
                      colorScheme: colorScheme,
                      theme: theme,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      TKeys.payToPostSubtitle.tr,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),

                    // Fee summary
                    Obx(() {
                      final salary = controller.salaryValue.value;
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: Column(
                          children: [
                            Row(children: [
                              Expanded(
                                child: Text(TKeys.jobBudget.tr,
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(color: colorScheme.onSurfaceVariant)),
                              ),
                              Text(
                                '৳${salary.toInt()} / ${controller.durationController.text}',
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ]),
                            const Divider(height: 18),
                            Row(children: [
                              Expanded(
                                child: Text(TKeys.platformFee.tr,
                                    style: theme.textTheme.titleSmall
                                        ?.copyWith(fontWeight: FontWeight.bold)),
                              ),
                              Text(
                                '৳300',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ]),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 16),
                    _FieldLabel(TKeys.paymentMethod.tr, theme),
                    const SizedBox(height: 8),

                    Obx(() {
                      if (controller.isLoadingPaymentMethods.value) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      }
                      if (controller.paymentMethodsList.isEmpty) {
                        return Text(TKeys.noData.tr);
                      }
                      return Column(
                        children: controller.paymentMethodsList.map((m) {
                          final isSelected =
                              controller.selectedPaymentMethod.value?.id == m.id;
                          final plainDesc =
                              (m.description.isNotEmpty ? m.description : m.account)
                                  .replaceAll(RegExp(r'<[^>]*>'), '')
                                  .trim();
                          return GestureDetector(
                            onTap: () => controller.selectedPaymentMethod.value = m,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colorScheme.primary.withValues(alpha: 0.06)
                                    : colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.borderColor,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: m.image.isNotEmpty
                                          ? Image.network(m.image,
                                              width: 36,
                                              height: 36,
                                              fit: BoxFit.contain,
                                              errorBuilder: (_, __, ___) => Icon(
                                                    Icons.payment_outlined,
                                                    color: colorScheme.primary,
                                                  ))
                                          : Icon(Icons.payment_outlined,
                                              color: colorScheme.primary),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        m.name,
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? colorScheme.primary
                                              : colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(Icons.check_circle_rounded,
                                          color: colorScheme.primary, size: 20),
                                  ]),
                                  if (isSelected && m.description.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Html(
                                      data: m.description,
                                      style: {
                                        'body': Style(
                                          margin: Margins.zero,
                                          padding: HtmlPaddings.zero,
                                          fontSize: FontSize(
                                              theme.textTheme.bodySmall?.fontSize ?? 12),
                                          color: colorScheme.onSurface,
                                          lineHeight: const LineHeight(1.3),
                                        ),
                                        'p': Style(
                                            margin: Margins.only(bottom: 2),
                                            padding: HtmlPaddings.zero),
                                        'li': Style(
                                            margin: Margins.only(bottom: 1),
                                            padding: HtmlPaddings.zero,
                                            lineHeight: const LineHeight(1.3)),
                                        'ol': Style(
                                            margin: Margins.only(
                                                left: 14, top: 2, bottom: 2),
                                            padding: HtmlPaddings.zero),
                                        'ul': Style(
                                            margin: Margins.only(
                                                left: 14, top: 2, bottom: 2),
                                            padding: HtmlPaddings.zero),
                                      },
                                    ),
                                  ] else if (!isSelected && plainDesc.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      plainDesc,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }),

                    const SizedBox(height: 12),
                    _FieldLabel(TKeys.transactionId.tr, theme),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: controller.transactionIdController,
                      decoration: InputDecoration(
                        hintText: TKeys.transactionIdHint.tr,
                        prefixIcon: const Icon(Icons.receipt_long_outlined),
                        border:
                            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty
                              ? TKeys.transactionIdRequired.tr
                              : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final ColorScheme colorScheme;
  final Widget child;

  const _SectionCard({required this.colorScheme, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: child,
      );
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      );
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final ThemeData theme;

  const _FieldLabel(this.text, this.theme);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
      );
}

class _CoverImagePicker extends StatelessWidget {
  final File? image;
  final VoidCallback onTap;

  const _CoverImagePicker({required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 160,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: image != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(image!, fit: BoxFit.cover),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.edit_outlined, size: 16),
                          const SizedBox(width: 6),
                          Text(TKeys.change.tr),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add_photo_alternate_outlined,
                        size: 28, color: colorScheme.onPrimaryContainer),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    TKeys.tapToSelectImage.tr,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
      ),
    );
  }
}
