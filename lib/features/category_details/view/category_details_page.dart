import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/common_app_bar.dart';
import '../controller/category_details_controller.dart';

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
            ],
          ),
        );
      }),
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