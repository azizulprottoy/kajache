import 'package:flutter/material.dart';

import '../../models/category_response_model.dart';
import '../../../../shared/shimmers/category_shimmer.dart';

class CategoryGrid extends StatelessWidget {
  final List<CategoryModel> categories;
  final bool isLoading;
  final void Function(CategoryModel category) onCategoryTap;

  const CategoryGrid({
    super.key,
    required this.categories,
    required this.isLoading,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoading && categories.isEmpty) {
      return const CategoryShimmer();
    }

    if (categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            'No categories available',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 6,
        crossAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];

        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => onCategoryTap(category),
          child: Container(

            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (category.imageLink.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      category.imageLink,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.category_outlined,
                        color: colorScheme.primary,
                        size: 34,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.category_outlined,
                    color: colorScheme.primary,
                    size: 34,
                  ),
                const SizedBox(height: 4),
                Text(
                  category.localizedName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}