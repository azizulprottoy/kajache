import 'package:get/get.dart';
import 'package:kaj_ache/features/home/repository/home_repository.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<HomeRepository>(() => HomeRepository(), fenix: true);

  }
}