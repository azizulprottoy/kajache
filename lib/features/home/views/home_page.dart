import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaj_ache/features/home/views/widgets/banner_slider.dart';
import 'package:kaj_ache/features/home/views/widgets/category_grid.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../../advertisements/widget/ad_banner.dart';
import '../../services/views/popular_services_list.dart';
import '../../../app/theme/context_extension.dart';
import '../../instantService/model/instant_service_model.dart';
import '../../recruitmentRequest/model/recruitment_request_model.dart';
import '../controllers/home_controller.dart';
import '../../../core/utils/media_url_helper.dart';

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

                  AdBanner(position: 'home_top'),

                  // TextField(
                  //   readOnly: true,
                  //   onTap: () {},
                  //   decoration: InputDecoration(
                  //     hintText: 'search_hint'.tr,
                  //     prefixIcon: const Icon(Icons.search),
                  //     filled: true,
                  //     fillColor: colorScheme.surfaceContainerLow,
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(12),
                  //       borderSide: BorderSide.none,
                  //     ),
                  //     contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  //   ),
                  // ),
                  //
                  // const SizedBox(height: 20),

                  BannerSlider(
                    banners: controller.banners,
                    currentIndex: controller.currentBannerIndex.value,
                    pageController: controller.bannerPageController,
                    onPageChanged: controller.onBannerPageChanged,
                  ),

                  const SizedBox(height: 2),

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



                  CategoryGrid(
                    categories: controller.categories,
                    isLoading: controller.isLoading.value,
                    onCategoryTap: controller.onCategoryTap,
                  ),



                  // ── Instant Service Requests ────────────────────────────
                  _HomeSection(
                    title: TKeys.availableInstantServices.tr,
                    icon: Icons.bolt_outlined,
                    onSeeAll: () => Get.toNamed(AppRoutes.myInstantServices),
                    theme: theme,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    if (controller.instantServices.isEmpty) {
                      return _HomeSectionEmpty(icon: Icons.bolt_outlined, colorScheme: colorScheme, theme: theme);
                    }
                    return SizedBox(
                      height: 180,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: controller.instantServices.map((item) =>
                          _HomeJobTile(
                            title: item.title,
                            subtitle: '৳${item.priceMin}–৳${item.priceMax}',
                            icon: Icons.bolt_outlined,
                            image: MediaUrlHelper.resolve(item.image),
                            onTap: () => Get.toNamed(AppRoutes.myInstantServiceDetails, arguments: item.id),
                            colorScheme: colorScheme,
                            theme: theme,
                          ),
                        ).toList(),
                      ),
                    );
                  }),



                  // ── Recruitment Requests ────────────────────────────────
                  _HomeSection(
                    title: TKeys.availableRecruitmentRequests.tr,
                    icon: Icons.badge_outlined,
                    onSeeAll: () => Get.toNamed(AppRoutes.myRecruitmentRequests),
                    theme: theme,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    if (controller.recruitmentPosts.isEmpty) {
                      return _HomeSectionEmpty(icon: Icons.badge_outlined, colorScheme: colorScheme, theme: theme);
                    }
                    return SizedBox(
                      height: 180,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: controller.recruitmentPosts.map((item) =>
                          _HomeJobTile(
                            title: item.title,
                            subtitle: '৳${item.salary.toInt()} • ${item.category}',
                            icon: Icons.badge_outlined,
                            image: MediaUrlHelper.resolve(item.image),
                            onTap: () => Get.toNamed(AppRoutes.myRecruitmentRequests),
                            colorScheme: colorScheme,
                            theme: theme,
                          ),
                        ).toList(),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  AdBanner(position: 'home_middle',padding: EdgeInsets.symmetric(vertical: 5),),

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

                  AdBanner(position: 'home_bottom'),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        )    );
  }
}

class _HomeSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onSeeAll;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _HomeSection({required this.title, required this.icon,
      required this.onSeeAll, required this.theme, required this.colorScheme});

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 18, color: colorScheme.primary),
    const SizedBox(width: 8),
    Expanded(child: Text(title, style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold, color: colorScheme.onSurface))),
    TextButton(onPressed: onSeeAll, child: Text(TKeys.seeAll.tr,
        style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.primary))),
  ]);
}

class _HomeJobTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String image;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _HomeJobTile({required this.title, required this.subtitle, required this.icon,
      this.image = '', required this.onTap, required this.colorScheme, required this.theme});

  Widget _iconBox() => Container(
    width: 150, height: 100,
    decoration: BoxDecoration(color: colorScheme.primaryContainer, borderRadius: BorderRadius.circular(7)),
    child: Icon(icon, color: colorScheme.onPrimaryContainer, size: 16),
  );

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 160,
      height: 150,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

            ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: image.isNotEmpty
                  ? Image.network(image, width: 150, height: 100, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _iconBox())
                  : _iconBox(),
            ),


          const SizedBox(height: 8),
          Text(title, style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    ),
  );
}

class _HomeSectionEmpty extends StatelessWidget {
  final IconData icon;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _HomeSectionEmpty({required this.icon, required this.colorScheme, required this.theme});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Center(
      child: Text('No posts yet', style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant)),
    ),
  );
}