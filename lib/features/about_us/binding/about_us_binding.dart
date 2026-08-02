import 'package:get/get.dart';
import '../controller/about_us_controller.dart';
import '../repository/about_us_repository.dart';

class AboutUsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AboutUsRepository>(() => AboutUsRepository(), fenix: true);
    Get.lazyPut<AboutUsController>(() => AboutUsController(), fenix: true);
  }
}
