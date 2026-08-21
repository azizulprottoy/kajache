import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/banner_response_model.dart';

class BannerSlider extends StatelessWidget {
  final List<AppBannerModel> banners;
  final int currentIndex;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;

  const BannerSlider({
    super.key,
    required this.banners,
    required this.currentIndex,
    required this.pageController,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (banners.isEmpty) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Shimmer.fromColors(
        baseColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        highlightColor: isDark ? Colors.grey.shade600 : Colors.grey.shade100,
        child: Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: pageController,
            itemCount: banners.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              final banner = banners[index];

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: colorScheme.surfaceContainerLowest,
                  image: banner.imageUrl.isNotEmpty
                      ? DecorationImage(
                    image: NetworkImage(banner.imageUrl),
                    fit: BoxFit.cover,
                    onError: (_, __) {},
                    // colorFilter: ColorFilter.mode(
                    //   Colors.black.withOpacity(0.35),
                    //   BlendMode.darken,
                    // ),
                  )
                      : null,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [


                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            banners.length,
                (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: currentIndex == index ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: currentIndex == index
                    ? colorScheme.primary
                    : colorScheme.primary.withOpacity(0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}