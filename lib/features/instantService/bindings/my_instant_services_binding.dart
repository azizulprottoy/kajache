import 'package:get/get.dart';

import '../controller/my_instant_services_controller.dart';
import '../repository/instant_service_repository.dart';

class MyInstantServicesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InstantServiceRepository>(
      () => InstantServiceRepository(),
      fenix: true,
    );
    Get.lazyPut<MyInstantServicesController>(
      () => MyInstantServicesController(),
      fenix: true,
    );
  }
}
