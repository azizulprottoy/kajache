import 'package:get/get.dart';

import '../controller/my_applications_controller.dart';

class MyApplicationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyApplicationsController>(
      () => MyApplicationsController(),
      fenix: true,
    );
  }
}
