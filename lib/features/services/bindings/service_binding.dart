import 'package:get/get.dart';

import '../controllers/all_services_controller.dart';
import '../repository/service_repository.dart';

class AllServicesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AllServicesRepository>(() => AllServicesRepository());
    Get.lazyPut<AllServicesController>(() => AllServicesController());
  }
}