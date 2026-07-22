import 'package:get/get.dart';
import '../controllers/shome_controller.dart';
import '../repository/shome_repository.dart';

class SHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SHomeRepository>(() => SHomeRepository(), fenix: true);
    Get.lazyPut<SHomeController>(() => SHomeController(), fenix: true);
  }
}
