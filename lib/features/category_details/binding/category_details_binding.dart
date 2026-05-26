import 'package:get/get.dart';

import '../controller/category_details_controller.dart';
import '../repository/category_details_repository.dart';

class CategoryDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoryDetailsRepository>(
          () => CategoryDetailsRepository(),
    );

    Get.lazyPut<CategoryDetailsController>(
          () => CategoryDetailsController(),
    );
  }
}