import 'package:get/get.dart';
import '../controllers/services_details_controller.dart';

class ServiceDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ServicesDetailsController>(() => ServicesDetailsController(),);
  }
}