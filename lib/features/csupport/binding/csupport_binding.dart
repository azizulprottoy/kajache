import 'package:get/get.dart';
import '../controller/csupport_controller.dart';

class CustomerSupportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerSupportController>(
          () => CustomerSupportController(),
      fenix: true,
    );
  }
}