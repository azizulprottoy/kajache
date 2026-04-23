import 'package:get/get.dart';
import 'package:kaj_ache/features/services/controllers/all_services_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../controller/main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<AllServicesController>(() => AllServicesController(), fenix: true);

  }
}