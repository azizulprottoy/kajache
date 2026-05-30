import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../controller/booking_controller.dart';

class BookingPage extends GetView<BookingController> {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CommonAppBar(
        title: 'Book Service',
        showBack: true,
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
      case 3:
        return _Step3Body(theme: theme, colorScheme: colorScheme);
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

  static const _steps = ['Service Scope', 'Logistics', 'Pay & Confirm'];

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
                      : colorScheme.outlineVariant.withOpacity(0.4),
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
          color: colorScheme.outlineVariant.withOpacity(0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.network(
            SImage,
            fit: BoxFit.cover,
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
            'Minimum Price: ৳${price.toInt()}',
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

        Text('Define the Scope',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Tell us exactly what you need done.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: colorScheme.onSurfaceVariant)),

        SizedBox(height: 20,),
        Text('Select Subservices (optional)',
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
                        : colorScheme.outlineVariant.withOpacity(0.5),
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
        Text('Problem Details *',
            style: theme.textTheme.labelLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.problemDetailsController,
          maxLines: 5,
          validator: (v) =>
          v == null || v.trim().isEmpty ? 'Please describe your problem' : null,
          decoration: InputDecoration(
            hintText:
            'Describe the problem in detail. The more you share, the better bids you\'ll receive...',
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
          'Logistics & Budget',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'Where, when, and how much?',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 20),

        /// Address
        TextFormField(
          controller: controller.addressController,
          decoration: InputDecoration(
            labelText: 'Service Address *',
            hintText: 'House #, Road, Area...',
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
              labelText: 'City',
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
                      return 'Select a date';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Date *',
                    hintText: 'Pick date',
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
                  hint: const Text('Pick time'),
                  decoration: InputDecoration(
                    labelText: 'Time Slot *',
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
                      return 'Select a time';
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
              return 'Minimum budget is 100 BDT';
            }

            return null;
          },
          decoration: InputDecoration(
            labelText: 'Maximum Budget (BDT) *',
            hintText: 'e.g. 2000',
            prefixIcon:
            const Icon(Icons.account_balance_wallet_outlined),
            helperText:
            'Providers won\'t bid above this amount.',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }
}
class _Step3Body extends GetView<BookingController> {
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _Step3Body({required this.theme, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text('Review & Pay',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('A small booking fee opens your request for bidding.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: 20),

        // Summary card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Service',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurfaceVariant,
                              letterSpacing: 1,
                            )),
                        const SizedBox(height: 4),
                        Text(controller.serviceTitle.value,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            )),
                        if (controller.selectedSubServices.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              controller.selectedSubServices.join(' · '),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Max Budget',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurfaceVariant,
                            letterSpacing: 1,
                          )),
                      const SizedBox(height: 4),
                      Text(
                        '${controller.budgetController.text} BDT',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _SummaryChip(
                    icon: Icons.location_on_outlined,
                    label: '${controller.addressController.text}, ${controller.selectedCity.value}',
                    colorScheme: colorScheme,
                    theme: theme,
                  ),
                  _SummaryChip(
                    icon: Icons.calendar_today_outlined,
                    label: controller.dateController.text,
                    colorScheme: colorScheme,
                    theme: theme,
                  ),
                  _SummaryChip(
                    icon: Icons.access_time_outlined,
                    label: controller.selectedTime.string,
                    colorScheme: colorScheme,
                    theme: theme,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Booking fee row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.35),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Booking Fee',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 2),
                    Text('Refundable if no provider is found',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        )),
                  ],
                ),
              ),
              Text('500 BDT',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  )),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Payment method
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.credit_card_outlined,
                      color: colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text('Payment Method',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: controller.paymentMethods.map((m) {
                  final isSelected =
                      controller.selectedPaymentMethod.value == m;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          right: m != controller.paymentMethods.last ? 10 : 0),
                      child: GestureDetector(
                        onTap: () =>
                        controller.selectedPaymentMethod.value = m,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.outlineVariant.withOpacity(0.5),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              m.toUpperCase(),
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    ));
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colorScheme.primary),
        const SizedBox(width: 4),
        Text(label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            )),
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
                  label: const Text('Back'),
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
                    : currentStep == 3
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
                    : currentStep == 3
                    ? const Icon(Icons.check, size: 18)
                    : const Icon(Icons.arrow_forward, size: 18),
                label: Text(
                  isLoading
                      ? 'Processing...'
                      : currentStep == 3
                      ? 'Confirm & Pay 500 BDT'
                      : 'Next',
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