import 'package:flutter/material.dart';
import '../../../app/theme/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../controller/booking_controller.dart';
import '../../../core/utils/translation_keys.dart';

class BookingPage extends GetView<BookingController> {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CommonAppBar(
        title: TKeys.bookService.tr,
        showLanguageToggle: true,
      ),
      body: Column(
        children: [


          Obx(() => _ServiceContextBar(
            title: controller.serviceTitle.value,
            price: controller.servicePrice.value,
            SImage: controller.serviceImage.value,
            colorScheme: colorScheme,
            theme: theme,
          )),

          Obx(() => _StepperHeader(
            currentStep: controller.currentStep.value,
            colorScheme: colorScheme,
            theme: theme,
          )),
          SizedBox(height: 20,),
          Obx(() => AnimatedSwitcher(
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
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Form(
                    key: controller.formKey,
                    child: _stepBody(context, theme, colorScheme),
                  ),
                ),
              ),
            )
            ),

SizedBox(height: 100,),
          Obx(() => _BottomNavBar(
            currentStep: controller.currentStep.value,
            isLoading: controller.isLoading.value,
            colorScheme: colorScheme,
            onBack: controller.prevStep,
            onNext: () => controller.nextStep(context),
            onConfirm: () => controller.submitBooking(
              ),          )),
        ],
      ),
    );
  }

  Widget _stepBody(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    switch (controller.currentStep.value) {
      case 1:
        return _Step1Body(theme: theme, colorScheme: colorScheme);
      case 2:
        return _Step2Body(context: context, theme: theme, colorScheme: colorScheme);
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

  static final _steps = [TKeys.serviceScope.tr, TKeys.logistics.tr];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: List.generate(_steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector line
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
                  boxShadow: isCurrent
                      ? [BoxShadow(
                    color: colorScheme.primary.withOpacity(0.25),
                    blurRadius: 8,
                    spreadRadius: 2,
                  )]
                      : null,
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

class _ServiceContextBar extends StatelessWidget {
  final String title;
  final String SImage;
  final double price;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _ServiceContextBar({
    required this.title,
    required this.SImage,
    required this.price,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SImage.isNotEmpty
                ? Image.network(
                    SImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.home_repair_service_outlined,
                      color: colorScheme.primary,
                    ),
                  )
                : Icon(
                    Icons.home_repair_service_outlined,
                    color: colorScheme.primary,
                  ),
          ),
          SizedBox(width: 10,),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            '${TKeys.minimumPrice.tr}: ৳${price.toInt()}',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}


class _Step1Body extends GetView<BookingController> {
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _Step1Body({required this.theme, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        Text(TKeys.defineScope.tr,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(TKeys.defineScopeSubtitle.tr,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: colorScheme.onSurfaceVariant)),

        SizedBox(height: 20,),
        Text(TKeys.selectSubservices.tr,
            style: theme.textTheme.labelLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        Obx(() => Wrap(
          spacing: 10,
          runSpacing: 10,
          children: controller.subServiceOptions.map((sub) {
            final isSelected = controller.selectedSubServices.contains(sub);
            return GestureDetector(
              onTap: () => controller.toggleSubService(sub),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary.withOpacity(0.08)
                      : colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.borderColor,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  sub,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }).toList(),
        )),

        const SizedBox(height: 20),

        // Problem details
        Text(TKeys.problemDetails.tr,
            style: theme.textTheme.labelLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.problemDetailsController,
          maxLines: 5,
          validator: (v) =>
          v == null || v.trim().isEmpty ? TKeys.describeProblemError.tr : null,
          decoration: InputDecoration(
            hintText:
            TKeys.problemDetailsHint.tr,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            alignLabelWithHint: true,
          ),
        ),

      ],
    );
  }
}

class _Step2Body extends GetView<BookingController> {
  final BuildContext context;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _Step2Body({
    required this.context,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        Text(
          TKeys.logisticsBudget.tr,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          TKeys.logisticsSubtitle.tr,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 20),

        /// Address
        TextFormField(
          controller: controller.addressController,
          decoration: InputDecoration(
            labelText: TKeys.serviceAddress.tr,
            hintText: TKeys.addressHint.tr,
            prefixIcon: const Icon(Icons.location_on_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        const SizedBox(height: 14),

        /// City Dropdown
        Obx(
              () => DropdownButtonFormField<String>(
            value: controller.selectedCity.value,
            decoration: InputDecoration(
              labelText: TKeys.city.tr,
              prefixIcon: const Icon(Icons.location_city_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            items: controller.cities
                .map(
                  (city) => DropdownMenuItem<String>(
                value: city,
                child: Text(city),
              ),
            )
                .toList(),
            onChanged: (value) {
              controller.selectedCity.value = value!;
            },
          ),
        ),

        const SizedBox(height: 14),

        /// Date & Time
        Row(
          children: [
            /// Date
            Expanded(
              child: GetBuilder<BookingController>(
                builder: (_) => TextFormField(
                  controller: controller.dateController,
                  readOnly: true,
                  onTap: () => controller.pickDate(context),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return TKeys.selectDate.tr;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: TKeys.dateLabel.tr,
                    hintText: TKeys.pickDate.tr,
                    prefixIcon:
                    const Icon(Icons.calendar_today_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            /// Time Slot
            Expanded(
              child: Obx(
                    () => DropdownButtonFormField<String>(
                  value: controller.selectedTime.value,
                  hint: Text(TKeys.pickTime.tr),
                  decoration: InputDecoration(
                    labelText: TKeys.timeSlot.tr,
                    prefixIcon:
                    const Icon(Icons.access_time_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  items: controller.timeSlots
                      .map(
                        (time) => DropdownMenuItem<String>(
                      value: time,
                      child: Text(time),
                    ),
                  )
                      .toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return TKeys.selectTime.tr;
                    }
                    return null;
                  },
                  onChanged: (value) {
                    controller.selectedTime.value = value;
                  },
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        /// Budget
        TextFormField(
          controller: controller.budgetController,
          keyboardType: TextInputType.number,
          validator: (value) {
            final amount = int.tryParse(value ?? '') ?? 0;

            if (amount < 100) {
              return TKeys.minBudgetError.tr;
            }

            return null;
          },
          decoration: InputDecoration(
            labelText: TKeys.maxBudgetLabel.tr,
            hintText: TKeys.budgetHint.tr,
            prefixIcon:
            const Icon(Icons.account_balance_wallet_outlined),
            helperText:
            TKeys.maxBudgetInfo.tr,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
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
                    : currentStep == BookingController.lastStep
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
                    : currentStep == BookingController.lastStep
                    ? const Icon(Icons.check, size: 18)
                    : const Icon(Icons.arrow_forward, size: 18),
                label: Text(
                  isLoading
                      ? TKeys.loading.tr
                      : currentStep == BookingController.lastStep
                      ? TKeys.bookingConfirm.tr
                      : TKeys.next.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}