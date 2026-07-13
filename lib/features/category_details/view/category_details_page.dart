import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/common_app_bar.dart';
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
      appBar: const CommonAppBar(
        title: 'Category Details',
        showLanguageToggle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.category.value == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final category = controller.category.value;

        if (category == null) {
          return Center(
            child: Text(
              'Category not found',
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
                  errorBuilder: (_, __, ___) => _ImageFallback(
                    colorScheme: colorScheme,
                  ),
                )
                    : _ImageFallback(
                  colorScheme: colorScheme,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                category.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                category.slug,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                category.description.isNotEmpty
                    ? category.description
                    : 'No description available',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Icon(
                    Icons.touch_app_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${category.clicks} clicks',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Divider(color: colorScheme.outlineVariant),
              const SizedBox(height: 12),

              Text(
                'Services',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),

              // Services list (reactive)
              if (controller.isServicesLoading.value)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (controller.services.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'No services available for this category',
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

    final features = service.features ?? const [];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  service.title ?? 'Untitled service',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              if (service.basePrice != null) ...[
                const SizedBox(width: 8),
                Text(
                  '৳${service.basePrice}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
          if ((service.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              service.description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
          if (features.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: features
                  .map(
                    (f) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    f.toString(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  final ColorScheme colorScheme;

  const _ImageFallback({
    required this.colorScheme,
  });

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