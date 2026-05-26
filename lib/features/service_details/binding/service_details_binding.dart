import 'package:get/get.dart';

import '../controller/service_details_controller.dart';
import '../repository/service_details_repository.dart';

class ServiceDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ServiceDetailsRepository>(
          () => ServiceDetailsRepository(),
    );

    Get.lazyPut<ServiceDetailsController>(
          () => ServiceDetailsController(),
    );
  }
}