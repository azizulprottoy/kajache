import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../arguments/service_argument.dart';
import '../controllers/all_services_controller.dart';

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
      body: RefreshIndicator(
        onRefresh: controller.fetchAllServices,
        child: Obx(() {
          if (controller.isLoading.value && controller.allServices.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.allServices.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 160),
                Icon(
                  Icons.home_repair_service_outlined,
                  size: 56,
                  color: colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'No services available',
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
            padding: const EdgeInsets.all(16),
            itemCount: controller.allServices.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final service = controller.allServices[index];

              return GestureDetector(
                onTap: () => Get.toNamed(
                  AppRoutes.serviceDetails,
                  arguments: ServiceArgument(
                    ServiceID: service.id,
                    isbooking: false,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withOpacity(0.1),
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
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.home_repair_service_outlined,
                          color: colorScheme.primary,
                          size: 32,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              service.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: service.status == 'active'
                                    ? Colors.green.withOpacity(0.12)
                                    : Colors.grey.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                service.status,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: service.status == 'active'
                                      ? Colors.green
                                      : Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
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

                            const SizedBox(height: 8),

                            CustomButton(
                              label: TKeys.bookNow.tr,
                              variant: ButtonVariant.primary,
                              size: ButtonSize.sm,
                              isFullWidth: true,
                              onPressed: () {
                                Get.toNamed(
                                  AppRoutes.bookingPage,
                                  arguments: ServiceArgument(
                                    ServiceID: service.id,
                                    isbooking: true,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}