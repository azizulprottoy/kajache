import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  RxBool isLoading = false.obs;

  // ── Banner ───────────────────────────────────────────────────────────────────
  final RxInt currentBannerIndex = 0.obs;

  final banners = [
    BannerModel(
      title: 'banner_1_title',
      subtitle: 'banner_1_subtitle',
      imageUrl: '',
    ),
    BannerModel(
      title: 'banner_2_title',
      subtitle: 'banner_2_subtitle',
      imageUrl: '',
    ),
    BannerModel(
      title: 'banner_3_title',
      subtitle: 'banner_3_subtitle',
      imageUrl: '',
    ),
  ];

  late PageController bannerPageController;
  Timer? _bannerTimer;

  // ── Categories ───────────────────────────────────────────────────────────────
  final categories = [
    CategoryModel(title: 'plumbing', icon: '🔧'),
    CategoryModel(title: 'stove_fixing', icon: '🔥'),
    CategoryModel(title: 'bathroom_cleaning', icon: '🚿'),
    CategoryModel(title: 'painting', icon: '🎨'),
    CategoryModel(title: 'electrician', icon: '⚡'),
    CategoryModel(title: 'carpentry', icon: '🪚'),
    CategoryModel(title: 'ac_repair', icon: '❄️'),
    CategoryModel(title: 'gardening', icon: '🌿'),
  ];

  // ── Popular Services ─────────────────────────────────────────────────────────
  final RxList<ServiceModel> popularServices = <ServiceModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    bannerPageController = PageController();
    fetchPopularServices();
    startBannerAutoSlide();
  }

  Future<void> fetchPopularServices() async {
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(seconds: 1));
      popularServices.assignAll([
        ServiceModel(
          id: '1',
          title: 'pipe_leak_fix',
          category: 'plumbing',
          rating: 4.8,
          reviews: 120,
          price: 500,
          imageUrl: '',
        ),
        ServiceModel(
          id: '2',
          title: 'full_bathroom_clean',
          category: 'bathroom_cleaning',
          rating: 4.6,
          reviews: 98,
          price: 800,
          imageUrl: '',
        ),
        ServiceModel(
          id: '3',
          title: 'stove_burner_repair',
          category: 'stove_fixing',
          rating: 4.7,
          reviews: 75,
          price: 400,
          imageUrl: '',
        ),
        ServiceModel(
          id: '4',
          title: 'room_painting',
          category: 'painting',
          rating: 4.9,
          reviews: 210,
          price: 3000,
          imageUrl: '',
        ),
      ]);
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void onBannerPageChanged(int index) {
    currentBannerIndex.value = index;
  }

  void startBannerAutoSlide() {
    _bannerTimer?.cancel();

    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!bannerPageController.hasClients || banners.isEmpty) return;

      int nextPage = currentBannerIndex.value + 1;
      if (nextPage >= banners.length) {
        nextPage = 0;
      }

      bannerPageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  void stopBannerAutoSlide() {
    _bannerTimer?.cancel();
  }

  @override
  void onClose() {
    _bannerTimer?.cancel();
    bannerPageController.dispose();
    super.onClose();
  }

  void onCategoryTap(CategoryModel category) {
    // TODO: navigate to category services page
  }

  void onServiceTap(ServiceModel service) {
    // TODO: navigate to service detail page
  }
}

// ── Models ───────────────────────────────────────────────────────────────────

class BannerModel {
  final String title;
  final String subtitle;
  final String imageUrl;

  BannerModel({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });
}

class CategoryModel {
  final String title;
  final String icon;

  CategoryModel({
    required this.title,
    required this.icon,
  });
}

class ServiceModel {
  final String id;
  final String title;
  final String category;
  final double rating;
  final int reviews;
  final double price;
  final String imageUrl;

  ServiceModel({
    required this.id,
    required this.title,
    required this.category,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.imageUrl,
  });
}