import 'package:get/get.dart';
import 'package:kaj_ache/features/services/controllers/all_services_controller.dart';

class ServiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AllServicesController>(() => AllServicesController(), fenix: true);
  }
}