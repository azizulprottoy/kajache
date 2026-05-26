import 'package:get/get.dart';
import 'package:kaj_ache/features/services/repository/service_repository.dart';
import '../../home/controllers/home_controller.dart';
import '../../home/controllers/shome_controller.dart';
import '../../home/repository/home_repository.dart';
import '../../services/controllers/all_services_controller.dart';
import '../../statistics/controller/statistics_controller.dart';
import '../controller/main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<SHomeController>(() => SHomeController(), fenix: true);
    Get.lazyPut<StatisticsController>(() => StatisticsController(), fenix: true);
    Get.lazyPut<AllServicesController>(() => AllServicesController(), fenix: true);
    Get.lazyPut<AllServicesRepository>(() => AllServicesRepository(), fenix: true);
    Get.lazyPut<HomeRepository>(() => HomeRepository(), fenix: true);

  }
}