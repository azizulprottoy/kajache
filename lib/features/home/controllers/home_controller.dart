import 'package:kaj_ache/core/error/api_error.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../category_details/arguments/category_details_arguments.dart';
import '../../service_details/arguments/service_details_arguments.dart';
import '../models/banner_response_model.dart';
import '../models/category_response_model.dart';
import '../models/services_response_model.dart';
import '../repository/home_repository.dart';
import '../../instantService/model/instant_service_model.dart';
import '../../instantService/repository/instant_service_repository.dart';
import '../../recruitmentRequest/model/recruitment_request_model.dart';
import '../../recruitmentRequest/repository/recruitment_request_repository.dart';

class HomeController extends GetxController {
  final HomeRepository _homeRepository = Get.find<HomeRepository>();
  final _instantRepo = InstantServiceRepository();
  final _recruitRepo = RecruitmentRequestRepository();

  final RxBool isLoading = false.obs;
  final RxList<InstantServiceModel> instantServices = <InstantServiceModel>[].obs;
  final RxList<RecruitmentRequestModel> recruitmentPosts = <RecruitmentRequestModel>[].obs;
  final RxInt currentIndex = 1.obs;
  final RxInt currentBannerIndex = 0.obs;

  final RxList<AppBannerModel> banners = <AppBannerModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<ServiceModel> popularServices = <ServiceModel>[].obs;

  late PageController bannerPageController;
  Timer? _bannerTimer;

  @override
  void onInit() {
    super.onInit();
    bannerPageController = PageController();
    fetchHomeData();
  }

  Future<void> fetchHomeData() async {
    isLoading.value = true;

    _fetchPublicLists();

    // Each section loads independently so one failing endpoint doesn't
    // hide the others; only the first error is shown.
    Object? firstError;
    Future<void> guard(Future<void> Function() load) async {
      try {
        await load();
      } catch (e) {
        firstError ??= e;
      }
    }

    await Future.wait([
      guard(fetchBanners),
      guard(fetchCategories),
      guard(fetchPopularServices),
    ]);

    if (isClosed) return;
    isLoading.value = false;
    final error = firstError;
    if (error != null) {
      Get.snackbar(
        'error'.tr,
        apiErrorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> fetchBanners() {
    return _homeRepository.getBanners().then((data) {
      banners.assignAll(data);

      if (banners.isNotEmpty) {
        currentBannerIndex.value = 0;
        startBannerAutoSlide();
      }
    });
  }

  Future<void> fetchCategories() {
    return _homeRepository.getCategories().then((data) {
      categories.assignAll(data);
    });
  }

  // Background lists: failures stay silent, but each loads on its own.
  Future<void> _fetchPublicLists() async {
    await Future.wait([
      _instantRepo.getAvailableInstantServices().then((list) {
        if (!isClosed) instantServices.assignAll(list);
      }).catchError((_) {}),
      _recruitRepo.getAvailableRecruitmentRequests().then((list) {
        if (!isClosed) recruitmentPosts.assignAll(list);
      }).catchError((_) {}),
    ]);
  }

  Future<void> fetchPopularServices() {
    return _homeRepository.getServices().then((data) {
      popularServices.assignAll(data);
    });
  }

  void onBannerPageChanged(int index) {
    currentBannerIndex.value = index;
  }

  void startBannerAutoSlide() {
    _bannerTimer?.cancel();

    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
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

  onCategoryTap(CategoryModel category) {
    Get.toNamed(
      AppRoutes.categoryDetails,
      arguments: CategoryDetailsArgument(categoryId: category.id,categorySlug: category.slug),
    );
  }

  void onServiceTap(ServiceModel service) {
    Get.toNamed(
      AppRoutes.serviceDetails,
      arguments: ServiceDetailsArgument(serviceSlug: service.slug),
    );  }
}