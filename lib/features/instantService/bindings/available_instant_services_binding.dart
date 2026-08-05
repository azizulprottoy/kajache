import 'package:get/get.dart';

import '../controller/available_instant_services_controller.dart';
import '../repository/instant_service_repository.dart';

class AvailableInstantServicesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InstantServiceRepository>(
      () => InstantServiceRepository(),
      fenix: true,
    );
    Get.lazyPut<AvailableInstantServicesController>(
      () => AvailableInstantServicesController(),
      fenix: true,
    );
  }
}
