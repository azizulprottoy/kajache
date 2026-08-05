import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../controller/instant_service_controller.dart';

/// Create/post form for an Instant Service — a customer posts an ad-hoc job
/// request, technicians bid on it, the customer selects a bidder and only
/// THEN pays the platform fee (see `InstantServiceController`).
class InstantServicePage extends GetView<InstantServiceController> {
  const InstantServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CommonAppBar(
        title: TKeys.postInstantService.tr,
        showLanguageToggle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.bolt_outlined, color: colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Post a job and get instant bids from nearby technicians.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              Text(TKeys.instantServiceTitleLabel.tr,
                  style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller.titleController,
                validator: (v) => v == null || v.trim().isEmpty
                    ? TKeys.describeProblemError.tr
                    : null,
                decoration: InputDecoration(
                  hintText: TKeys.instantServiceTitleHint.tr,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),

              const SizedBox(height: 18),

              Text(TKeys.problemDetails.tr,
                  style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller.detailsController,
                maxLines: 5,
                validator: (v) => v == null || v.trim().isEmpty
                    ? TKeys.describeProblemError.tr
                    : null,
                decoration: InputDecoration(
                  hintText: TKeys.problemDetailsHint.tr,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller.priceMinController,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final n = int.tryParse(v?.trim() ?? '');
                        return n == null || n <= 0 ? TKeys.enterPrice.tr : null;
                      },
                      decoration: InputDecoration(
                        labelText: TKeys.priceMin.tr,
                        hintText: TKeys.priceRangeHint.tr,
                        prefixText: '৳ ',
                        prefixIcon: const Icon(Icons.arrow_downward_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: controller.priceMaxController,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final n = int.tryParse(v?.trim() ?? '');
                        return n == null || n <= 0 ? TKeys.enterPrice.tr : null;
                      },
                      decoration: InputDecoration(
                        labelText: TKeys.priceMax.tr,
                        hintText: TKeys.priceRangeHint.tr,
                        prefixText: '৳ ',
                        prefixIcon: const Icon(Icons.arrow_upward_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              TextFormField(
                controller: controller.addressController,
                validator: (v) => v == null || v.trim().isEmpty
                    ? TKeys.addressRequired.tr
                    : null,
                decoration: InputDecoration(
                  labelText: TKeys.serviceAddress.tr,
                  hintText: TKeys.addressHint.tr,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),

              const SizedBox(height: 14),

              Obx(
                () => DropdownButtonFormField<String>(
                  value: controller.selectedCity.value,
                  decoration: InputDecoration(
                    labelText: TKeys.city.tr,
                    prefixIcon: const Icon(Icons.location_city_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  items: controller.cities
                      .map((city) => DropdownMenuItem<String>(value: city, child: Text(city)))
                      .toList(),
                  onChanged: (value) => controller.selectedCity.value = value!,
                ),
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller: controller.districtController,
                decoration: InputDecoration(
                  labelText: '${TKeys.district.tr} (optional)',
                  prefixIcon: const Icon(Icons.map_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),

              const SizedBox(height: 18),

              Text('Schedule (optional)',
                  style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GetBuilder<InstantServiceController>(
                      builder: (_) => TextFormField(
                        controller: controller.dateController,
                        readOnly: true,
                        onTap: () => controller.pickDate(context),
                        decoration: InputDecoration(
                          labelText: TKeys.dateLabel.tr,
                          hintText: TKeys.pickDate.tr,
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => DropdownButtonFormField<String>(
                        value: controller.selectedTime.value,
                        hint: Text(TKeys.pickTime.tr),
                        decoration: InputDecoration(
                          labelText: TKeys.timeSlot.tr,
                          prefixIcon: const Icon(Icons.access_time_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        items: controller.timeSlots
                            .map((time) => DropdownMenuItem<String>(value: time, child: Text(time)))
                            .toList(),
                        onChanged: (value) => controller.selectedTime.value = value,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.submitInstantService,
                    icon: controller.isLoading.value
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.bolt_outlined, size: 18),
                    label: Text(
                      controller.isLoading.value
                          ? TKeys.loading.tr
                          : TKeys.postInstantService.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
