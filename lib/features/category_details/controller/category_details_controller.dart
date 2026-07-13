import 'package:get/get.dart';

import '../../home/models/category_response_model.dart';
import '../arguments/category_details_arguments.dart';
import '../model/category_services_response_model.dart';
import '../repository/category_details_repository.dart';

class CategoryDetailsController extends GetxController {
  final CategoryDetailsRepository _repository;

  CategoryDetailsController({CategoryDetailsRepository? repository})
      : _repository = repository ?? CategoryDetailsRepository();

  // State
  final Rxn<CategoryModel> category = Rxn<CategoryModel>();
  final RxList<Datum> services = <Datum>[].obs;

  final RxBool isLoading = false.obs;          // category details
  final RxBool isServicesLoading = false.obs;  // services list
  final RxString errorMessage = ''.obs;
  late final String categoryId;
  late final String categorySlug;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    if (args is CategoryDetailsArgument) {
      categoryId = args.categoryId;
      categorySlug = args.categorySlug;
      fetchCategoryDetails();
      fetchServices(categorySlug);

    } else {
      Get.back();
      Get.snackbar(
        'Error',
        'Category ID not found',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> fetchCategoryDetails() {
    isLoading.value = true;

    return _repository
        .getCategoryById(categoryId)
        .then((data) {
      category.value = data;
    })
        .catchError((error) {
      Get.snackbar(
        'Error',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    })
        .whenComplete(() {
      isLoading.value = false;
    });
  }

  Future<void> fetchServices(String categorySlug) async {
    try {
      isServicesLoading.value = true;
      final result = await _repository.getServicesbyCategory(categorySlug);
      services.assignAll(result ?? <Datum>[]);
    } catch (_) {

      services.clear();
    } finally {
      isServicesLoading.value = false;
    }
  }
}