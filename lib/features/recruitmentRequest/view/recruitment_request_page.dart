import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/context_extension.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../controller/recruitment_request_controller.dart';

/// Step 1: job details (title, details, duration, salary).
/// Step 2: pay-to-post (payment method + transaction id) — the posting fee
/// must be paid BEFORE bidding opens, unlike Booking/Instant Service where
/// payment happens after a bid is selected.
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
      body: Column(
        children: [
          Obx(() => _StepperHeader(
                currentStep: controller.currentStep.value,
                colorScheme: colorScheme,
                theme: theme,
              )),
          Expanded(
            child: Obx(() => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(controller.currentStep.value),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Form(
                        key: controller.formKey,
                        child: _stepBody(theme, colorScheme),
                      ),
                    ),
                  ),
                )),
          ),
          Obx(() => _BottomNavBar(
                currentStep: controller.currentStep.value,
                isLoading: controller.isLoading.value,
                colorScheme: colorScheme,
                onBack: controller.prevStep,
                onNext: () => controller.nextStep(context),
                onConfirm: controller.submitRequest,
              )),
        ],
      ),
    );
  }

  Widget _stepBody(ThemeData theme, ColorScheme colorScheme) {
    switch (controller.currentStep.value) {
      case 1:
        return _Step1Body(theme: theme, colorScheme: colorScheme);
      case 2:
        return _Step2Body(theme: theme, colorScheme: colorScheme);
      default:
        return const SizedBox();
    }
  }
}

class _StepperHeader extends StatelessWidget {
  final int currentStep;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _StepperHeader({
    required this.currentStep,
    required this.colorScheme,
    required this.theme,
  });

  static final _steps = [TKeys.recruitmentDetailsLabel.tr, TKeys.payToPost.tr];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: List.generate(_steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final stepIndex = i ~/ 2;
            final isCompleted = currentStep > stepIndex + 1;
            return Expanded(
              child: Container(
                height: 3,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? colorScheme.primary
                      : colorScheme.borderColor,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            );
          }

          final stepIndex = i ~/ 2;
          final stepNum = stepIndex + 1;
          final isCompleted = currentStep > stepNum;
          final isCurrent = currentStep == stepNum;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted || isCurrent
                      ? colorScheme.primary
                      : colorScheme.surface,
                  border: Border.all(
                    color: isCompleted || isCurrent
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? Icon(Icons.check, size: 16, color: colorScheme.onPrimary)
                      : Text(
                          '$stepNum',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isCurrent
                                ? colorScheme.onPrimary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _steps[stepIndex],
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isCurrent || isCompleted
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _Step1Body extends GetView<RecruitmentRequestController> {
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _Step1Body({required this.theme, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.badge_outlined, color: colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Hire a technician long-term. A platform fee is required upfront to publish the post before technicians can apply.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Text('Job Title',
            style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.titleController,
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Please enter a job title' : null,
          decoration: InputDecoration(
            hintText: 'e.g. Full-time AC Technician',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 16),

        Text(TKeys.recruitmentDetailsLabel.tr,
            style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.detailsController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: TKeys.recruitmentDetailsHint.tr,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 16),

        Text(TKeys.durationLabel.tr,
            style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.durationController,
          validator: (v) =>
              v == null || v.trim().isEmpty ? TKeys.durationHint.tr : null,
          decoration: InputDecoration(
            hintText: TKeys.durationHint.tr,
            prefixIcon: const Icon(Icons.schedule_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 16),

        Text(TKeys.salaryLabel.tr,
            style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.salaryController,
          keyboardType: TextInputType.number,
          onChanged: (v) => controller.salaryValue.value = double.tryParse(v.trim()) ?? 0,
          validator: (v) {
            final n = num.tryParse(v?.trim() ?? '');
            if (n == null || n <= 0) return 'Please enter a valid salary';
            return null;
          },
          decoration: InputDecoration(
            hintText: TKeys.salaryHint.tr,
            prefixIcon: const Icon(Icons.payments_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }
}

class _Step2Body extends GetView<RecruitmentRequestController> {
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _Step2Body({required this.theme, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          TKeys.payToPost.tr,
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          TKeys.payToPostSubtitle.tr,
          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),

        Obx(() {
          final salary = controller.salaryValue.value;
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.borderColor),
            ),
            child: Column(
              children: [
                Row(children: [
                  Expanded(
                    child: Text(TKeys.jobBudget.tr,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ),
                  Text('৳${salary.toInt()} / ${controller.durationController.text}',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ]),
                const Divider(height: 20),
                Row(children: [
                  Expanded(
                    child: Text(TKeys.platformFee.tr,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  Text('৳300',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      )),
                ]),
              ],
            ),
          );
        }),

        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(TKeys.paymentMethod.tr,
              style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10),
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
              final isSelected = controller.selectedPaymentMethod.value?.id == m.id;
              final desc = m.description.isNotEmpty ? m.description : m.account;
              return GestureDetector(
                onTap: () => controller.selectedPaymentMethod.value = m,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary.withValues(alpha: 0.06)
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? colorScheme.primary : colorScheme.borderColor,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: m.image.isNotEmpty
                          ? Image.network(
                              m.image,
                              width: 36,
                              height: 36,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.payment_outlined,
                                color: colorScheme.primary,
                              ),
                            )
                          : Icon(Icons.payment_outlined, color: colorScheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                              )),
                          if (desc.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(desc,
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: colorScheme.onSurfaceVariant),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle_rounded, color: colorScheme.primary, size: 20),
                  ]),
                ),
              );
            }).toList(),
          );
        }),

        const SizedBox(height: 16),
        TextFormField(
          controller: controller.transactionIdController,
          decoration: InputDecoration(
            labelText: TKeys.transactionId.tr,
            hintText: TKeys.transactionIdHint.tr,
            prefixIcon: const Icon(Icons.receipt_long_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          validator: (v) =>
              v == null || v.trim().isEmpty ? TKeys.transactionIdRequired.tr : null,
        ),
      ],
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int currentStep;
  final bool isLoading;
  final ColorScheme colorScheme;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onConfirm;

  const _BottomNavBar({
    required this.currentStep,
    required this.isLoading,
    required this.colorScheme,
    required this.onBack,
    required this.onNext,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            if (currentStep > 1) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : onBack,
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: Text(TKeys.back.tr),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: isLoading
                    ? null
                    : currentStep == RecruitmentRequestController.lastStep
                        ? onConfirm
                        : onNext,
                icon: isLoading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : currentStep == RecruitmentRequestController.lastStep
                        ? const Icon(Icons.check, size: 18)
                        : const Icon(Icons.arrow_forward, size: 18),
                label: Text(
                  isLoading
                      ? TKeys.loading.tr
                      : currentStep == RecruitmentRequestController.lastStep
                          ? TKeys.payNow.tr
                          : TKeys.next.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
