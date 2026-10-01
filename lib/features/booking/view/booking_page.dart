import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/context_extension.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../../../core/utils/translation_keys.dart';
import '../controller/booking_controller.dart';
import 'widgets/map_location_picker.dart';
import 'package:kaj_ache/shared/widgets/app_network_image.dart';

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
          Obx(
            () => _ServiceContextBar(
              title: controller.serviceTitle.value,
              price: controller.servicePrice.value,
              SImage: controller.serviceImage.value,
              colorScheme: colorScheme,
              theme: theme,
            ),
          ),

          // Single page, same as the website booking form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Form(
                key: controller.formKey,
                child: _BookingFormBody(theme: theme, colorScheme: colorScheme),
              ),
            ),
          ),

          Obx(
            () => _ConfirmBar(
              isLoading: controller.isLoading.value,
              colorScheme: colorScheme,
              onSaveDraft: () => controller.submitBooking(asDraft: true),
              onConfirm: controller.submitBooking,
            ),
          ),
        ],
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
        border: Border.all(color: colorScheme.borderColor),
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
                ? AppNetworkImage(
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
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (price > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${TKeys.bidsStartFrom.tr} ৳${price.toInt()}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingFormBody extends GetView<BookingController> {
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _BookingFormBody({required this.theme, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Title
        TextFormField(
          controller: controller.titleController,
          textCapitalization: TextCapitalization.sentences,
          validator: (v) =>
              v == null || v.trim().isEmpty ? TKeys.titleRequired.tr : null,
          decoration: InputDecoration(
            labelText: TKeys.bookingTitle.tr,
            hintText: TKeys.bookingTitleHint.tr,
            prefixIcon: const Icon(Icons.title_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),

        const SizedBox(height: 14),

        // Problem details
        TextFormField(
          controller: controller.problemDetailsController,
          maxLines: 5,
          validator: (v) => v == null || v.trim().isEmpty
              ? TKeys.describeProblemError.tr
              : null,
          decoration: InputDecoration(
            labelText: TKeys.problemDetails.tr,
            hintText: TKeys.problemDetailsHint.tr,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            alignLabelWithHint: true,
          ),
        ),

        const SizedBox(height: 14),

        // Photos
        Text(
          TKeys.photosLabel.tr,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < controller.photos.length; i++)
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        controller.photos[i],
                        width: 76,
                        height: 76,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: -6,
                      right: -6,
                      child: GestureDetector(
                        onTap: () => controller.removePhoto(i),
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: colorScheme.error,
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: colorScheme.onError,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              if (controller.photos.length < BookingController.maxPhotos)
                GestureDetector(
                  onTap: controller.pickPhotos,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.borderColor),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          TKeys.addPhotos.tr,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        /// Map location picker button
        Obx(() {
          final hasPin = controller.pickedLat.value != null;
          return GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MapLocationPicker()),
              );
              if (result is PickedLocation) {
                controller.pickedLat.value = result.lat;
                controller.pickedLng.value = result.lng;
                controller.pickedDistrict.value = result.district;
                controller.pickedArea.value = result.area;
                controller.applyPickedDistrict(result.district);
                controller.addressController.text = result.address;
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: hasPin
                    ? colorScheme.primaryContainer.withValues(alpha: 0.4)
                    : colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: hasPin ? colorScheme.primary : colorScheme.borderColor,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.map_outlined,
                    color: hasPin
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      hasPin
                          ? controller.addressController.text.isNotEmpty
                                ? controller.addressController.text
                                : '${controller.pickedLat.value!.toStringAsFixed(5)}, ${controller.pickedLng.value!.toStringAsFixed(5)}'
                          : TKeys.pinOnMap.tr,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: hasPin
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 14),

        /// Address (manual fallback)
        TextFormField(
          controller: controller.addressController,
          validator: (v) =>
              v == null || v.trim().isEmpty ? TKeys.addressRequired.tr : null,
          decoration: InputDecoration(
            labelText: TKeys.serviceAddress.tr,
            hintText: TKeys.addressHint.tr,
            prefixIcon: const Icon(Icons.location_on_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),

        const SizedBox(height: 14),

        /// District
        Obx(() {
          final names = controller.districts.map((d) => d.name).toList();
          final selected = controller.selectedDistrict.value;
          return DropdownButtonFormField<String>(
            // A map-picked name that isn't in the list can't be the dropdown value
            value: names.contains(selected) ? selected : null,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: TKeys.district.tr,
              prefixIcon: const Icon(Icons.map_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            items: controller.districts
                .map(
                  (d) => DropdownMenuItem<String>(
                    value: d.name,
                    child: Text(
                      d.localizedName(Get.locale?.languageCode == 'bn'),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) => controller.selectedDistrict.value = value,
          );
        }),

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
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
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
                    prefixIcon: const Icon(Icons.access_time_outlined),
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

      ],
    );
  }
}

class _ConfirmBar extends StatelessWidget {
  final bool isLoading;
  final ColorScheme colorScheme;
  final VoidCallback onSaveDraft;
  final VoidCallback onConfirm;

  const _ConfirmBar({
    required this.isLoading,
    required this.colorScheme,
    required this.onSaveDraft,
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
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading ? null : onSaveDraft,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(TKeys.saveAsDraft.tr, textAlign: TextAlign.center),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: isLoading ? null : onConfirm,
                icon: isLoading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.check, size: 18),
                label: Text(
                  isLoading ? TKeys.loading.tr : TKeys.bookingConfirm.tr,
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
