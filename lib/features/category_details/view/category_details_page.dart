import 'package:flutter/material.dart';
import '../../../app/theme/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/utils/translation_keys.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../../../shared/widgets/custom_button.dart'; // CustomButton, ButtonVariant, ButtonSize
import '../../../shared/shimmers/category_details_shimmer.dart';
import '../../service_details/arguments/service_details_arguments.dart';
import '../controller/category_details_controller.dart';
import '../model/category_services_response_model.dart';

class CategoryDetailsPage extends GetView<CategoryDetailsController> {
  const CategoryDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CommonAppBar(
        title: TKeys.categoryDetails.tr,
        showLanguageToggle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.category.value == null) {
          return const CategoryDetailsShimmer();
        }

        final category = controller.category.value;

        if (category == null) {
          return Center(
            child: Text(
              TKeys.categoryNotFound.tr,
              style: theme.textTheme.titleMedium,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchCategoryDetails,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: category.imageLink.isNotEmpty
                    ? Image.network(
                  category.imageLink,
                  height: 190,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _ImageFallback(colorScheme: colorScheme),
                )
                    : _ImageFallback(colorScheme: colorScheme),
              ),

              const SizedBox(height: 10),

              Text(
                category.localizedName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),

              if (category.localizedDescription.isNotEmpty)
                Html(
                  data: category.localizedDescription,
                  style: {
                    'body': Style(
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                      color: colorScheme.onSurfaceVariant,
                      fontSize: FontSize(theme.textTheme.bodyMedium?.fontSize ?? 14),
                      lineHeight: const LineHeight(1.5),
                    ),
                  },
                )
              else
                Text(
                  TKeys.noDescription.tr,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),



              Text(
                TKeys.services.tr,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),

              // Services list (reactive)
              if (controller.isServicesLoading.value)
                const CategoryServicesShimmer()
              else if (controller.services.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    TKeys.noServicesInCategory.tr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                ...controller.services.map(
                      (service) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ServiceCard(service: service),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Datum service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // final imageUrl = service.imageLink ?? '';

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.serviceDetails,
        arguments: ServiceDetailsArgument(serviceSlug: service.slug ?? ''),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Container(
              width: 72,
              height: 72,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child:
              // imageUrl.isNotEmpty
              //     ? Image.network(
              //   imageUrl,
              //   width: 72,
              //   height: 72,
              //   fit: BoxFit.cover,
              //   errorBuilder: (_, __, ___) => Icon(
              //     Icons.home_repair_service_outlined,
              //     color: colorScheme.primary,
              //     size: 28,
              //   ),
              // )
              //     :
              Icon(
                Icons.home_repair_service_outlined,
                color: colorScheme.primary,
                size: 28,
              ),
            ),

            const SizedBox(width: 12),

            // Title + description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.localizedTitle.isNotEmpty
                        ? service.localizedTitle
                        : TKeys.untitledService.tr,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.localizedDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Text(
              '৳${service.basePrice ?? 0}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  final ColorScheme colorScheme;

  const _ImageFallback({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.category_outlined,
        size: 56,
        color: colorScheme.primary,
      ),
    );
  }
}