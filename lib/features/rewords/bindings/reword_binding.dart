import 'package:get/get.dart';
import '../controllers/reword_controller.dart';

class RewardsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RewardsController>(() => RewardsController(), fenix: true);
  }
}