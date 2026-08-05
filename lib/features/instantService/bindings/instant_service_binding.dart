import 'package:get/get.dart';

import '../controller/instant_service_controller.dart';
import '../repository/instant_service_repository.dart';

class InstantServiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InstantServiceRepository>(
      () => InstantServiceRepository(),
      fenix: true,
    );
    Get.lazyPut<InstantServiceController>(
      () => InstantServiceController(),
      fenix: true,
    );
  }
}
