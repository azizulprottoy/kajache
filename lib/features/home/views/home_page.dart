import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaj_ache/features/home/views/widgets/banner_slider.dart';
import 'package:kaj_ache/features/home/views/widgets/category_grid.dart';

import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../../services/views/popular_services_list.dart';
import '../controllers/home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CommonAppBar(
        title: 'app_name',
        showLanguageToggle: true,
      ),
        body: RefreshIndicator(
          onRefresh: controller.fetchHomeData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(
                  () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  TextField(
                    readOnly: true,
                    onTap: () {},
                    decoration: InputDecoration(
                      hintText: 'search_hint'.tr,
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),

                  const SizedBox(height: 20),

                  BannerSlider(
                    banners: controller.banners,
                    currentIndex: controller.currentBannerIndex.value,
                    pageController: controller.bannerPageController,
                    onPageChanged: controller.onBannerPageChanged,
                  ),

                  const SizedBox(height: 6),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        TKeys.categories.tr,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          TKeys.seeAll.tr,
                          style: TextStyle(color: colorScheme.primary),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  CategoryGrid(
                    categories: controller.categories,
                    isLoading: controller.isLoading.value,
                    onCategoryTap: controller.onCategoryTap,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        TKeys.popularServices.tr,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          TKeys.seeAll.tr,
                          style: TextStyle(color: colorScheme.primary),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  PopularServicesList(
                    services: controller.popularServices,
                    isLoading: controller.isLoading.value,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        )    );
  }
}