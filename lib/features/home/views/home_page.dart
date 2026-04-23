import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaj_ache/features/home/views/widgets/banner_slider.dart';
import 'package:kaj_ache/features/home/views/widgets/category_grid.dart';
import '../../../core/controller/local_controller.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../../services/views/popular_services_list.dart';
import '../controllers/home_controller.dart';
import '../../../shared/widgets/common_nav_bar.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localeController = Get.find<LocaleController>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CommonAppBar(
        title: 'app_name',
        showLanguageToggle: true,
      ),
      bottomNavigationBar: CommonBottomNavBar(
        currentIndex: localeController.currentIndex.value,
        onTap: localeController.changeNavIndex,
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchPopularServices,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
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
              const BannerSlider(),
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
              const CategoryGrid(),
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
              const PopularServicesList(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}