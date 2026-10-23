import 'package:kaj_ache/core/error/api_error.dart';
import 'package:get/get.dart';

import '../../home/models/category_response_model.dart';
import '../../home/models/services_response_model.dart';
import '../repository/service_repository.dart';

/// Services page: every service, filtered on the device by a category chip
/// and a search box (same as the website's services page).
class AllServicesController extends GetxController {
  final AllServicesRepository _repository = Get.find<AllServicesRepository>();

  final RxBool isLoading = false.obs;
  final RxList<ServiceModel> allServices = <ServiceModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  /// null = all categories
  final RxnString selectedCategoryId = RxnString();
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Optional starting category, e.g. Get.toNamed(AppRoutes.allServices, arguments: categoryId)
    final initialCategory = Get.arguments;
    if (initialCategory is String && initialCategory.isNotEmpty) {
      selectedCategoryId.value = initialCategory;
    }
    fetchAllServices();
  }

  /// Chips: only categories that have at least one service
  List<CategoryModel> get categoriesWithServices {
    final used = allServices.map((s) => s.categoryId).toSet();
    return categories.where((c) => used.contains(c.id)).toList();
  }

  List<ServiceModel> get filteredServices {
    final query = searchQuery.value.trim().toLowerCase();
    final categoryId = selectedCategoryId.value;
    return allServices.where((s) {
      if (categoryId != null && s.categoryId != categoryId) return false;
      if (query.isEmpty) return true;
      return [s.title, s.titleBn, s.description, s.descriptionBn]
          .any((text) => text.toLowerCase().contains(query));
    }).toList();
  }

  void selectCategory(String? categoryId) => selectedCategoryId.value = categoryId;

  Future<void> fetchAllServices() {
    isLoading.value = true;

    return Future.wait([
      _repository.getAllServices().then(allServices.assignAll),
      // Chips are optional: without categories the page still lists services
      _repository.getCategories().then(categories.assignAll).catchError((_) {}),
    ]).catchError((error) {
      Get.snackbar(
        'error'.tr,
        apiErrorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
      return <void>[];
    }).whenComplete(() {
      isLoading.value = false;
    });
  }
}
