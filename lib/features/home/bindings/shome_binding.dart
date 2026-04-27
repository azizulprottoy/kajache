import 'package:get/get.dart';
import '../controllers/shome_controller.dart';

class SHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SHomeController>(() => SHomeController(), fenix: true);
  }
}