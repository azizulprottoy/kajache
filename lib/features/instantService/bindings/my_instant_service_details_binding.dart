import 'package:get/get.dart';

import '../controller/my_instant_service_details_controller.dart';
import '../repository/instant_service_repository.dart';

class MyInstantServiceDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InstantServiceRepository>(
      () => InstantServiceRepository(),
      fenix: true,
    );
    Get.lazyPut<MyInstantServiceDetailsController>(
      () => MyInstantServiceDetailsController(),
    );
  }
}
