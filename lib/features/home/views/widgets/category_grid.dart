import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaj_ache/app/theme/app_colors.dart';
import '../../controllers/home_controller.dart';

class CategoryGrid extends GetView<HomeController> {
  const CategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final theme       = Theme.of(context);

    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.categories.length,
      gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 5,
        crossAxisSpacing: 10,
        childAspectRatio: 0.90,
      ),
      itemBuilder: (context, index) {
        final category = controller.categories[index];
        return GestureDetector(
          onTap: () => controller.onCategoryTap(category),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  category.icon,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                category.title.tr,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color:  AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}