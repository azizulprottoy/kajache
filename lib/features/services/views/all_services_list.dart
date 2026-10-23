import 'package:flutter/material.dart';
import '../../../app/theme/context_extension.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../shared/shimmers/popular_services_shimmer.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../../service_details/arguments/service_details_arguments.dart';
import '../../../core/utils/media_url_helper.dart';
import '../../../core/utils/html_text.dart';
import '../../../core/utils/translation_keys.dart';
import '../../home/models/services_response_model.dart';
import '../controllers/all_services_controller.dart';
import 'package:kaj_ache/shared/widgets/app_network_image.dart';

class AllServices extends GetView<AllServicesController> {
  const AllServices({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CommonAppBar(
        title: 'Services',
        showLanguageToggle: true,
      ),
      body: Column(
        children: [
          // Search + category chips, like the website's services page
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => controller.searchQuery.value = v,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: TKeys.searchServices.tr,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Obx(() {
            final chips = controller.categoriesWithServices;
            if (chips.isEmpty) return const SizedBox.shrink();
            final selected = controller.selectedCategoryId.value;
            return SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                children: [
                  _CategoryChip(
                    label: TKeys.allServices.tr,
                    selected: selected == null,
                    onTap: () => controller.selectCategory(null),
                  ),
                  for (final category in chips)
                    _CategoryChip(
                      label: category.localizedName,
                      selected: selected == category.id,
                      onTap: () => controller.selectCategory(category.id),
                    ),
                ],
              ),
            );
          }),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.fetchAllServices,
              child: Obx(() {
                if (controller.isLoading.value && controller.allServices.isEmpty) {
                  return const AllServicesShimmer();
                }

                final services = controller.filteredServices;
                if (services.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.12),
                      Icon(
                        Icons.home_repair_service_outlined,
                        size: 56,
                        color: colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          controller.allServices.isEmpty
                              ? TKeys.noServicesAvailable.tr
                              : TKeys.noServicesInCategory.tr,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    16 + MediaQuery.of(context).padding.bottom,
                  ),
                  itemCount: services.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _ServiceCard(service: services[index]),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        selectedColor: colorScheme.primary,
        labelStyle: TextStyle(
          color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.serviceDetails,
        arguments: ServiceDetailsArgument(serviceSlug: service.slug

        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colorScheme.borderColor,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              child: () {
                final img = MediaUrlHelper.resolve(service.image);
                return img.isNotEmpty
                    ? AppNetworkImage(
                        img,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.home_repair_service_outlined,
                          color: colorScheme.primary,
                          size: 32,
                        ),
                      )
                    : Icon(
                        Icons.home_repair_service_outlined,
                        color: colorScheme.primary,
                        size: 32,
                      );
              }(),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.localizedTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    htmlToPlainText(service.localizedDescription),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

                ],
              ),
            ),

            SizedBox(
              width: 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '৳${service.basePrice.toInt()}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),

                  // const SizedBox(height: 8),
                  //
                  // CustomButton(
                  //   label: TKeys.bookNow.tr,
                  //   variant: ButtonVariant.primary,
                  //   size: ButtonSize.sm,
                  //   isFullWidth: true,
                  //   onPressed: () {
                  //     Get.toNamed(
                  //       AppRoutes.bookingPage,
                  //       arguments: ServiceArgument(
                  //         ServiceID: service.id,
                  //         isbooking: true,
                  //       ),
                  //     );
                  //   },
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
