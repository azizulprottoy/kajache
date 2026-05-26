import 'package:get/get.dart';

import '../../home/models/category_response_model.dart';
import '../arguments/category_details_arguments.dart';
import '../repository/category_details_repository.dart';



class CategoryDetailsController extends GetxController {
  final CategoryDetailsRepository _repository =
  Get.find<CategoryDetailsRepository>();

  final RxBool isLoading = false.obs;
  final Rxn<CategoryModel> category = Rxn<CategoryModel>();

  late final String categoryId;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    if (args is CategoryDetailsArgument) {
      categoryId = args.categoryId;
      fetchCategoryDetails();
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
}