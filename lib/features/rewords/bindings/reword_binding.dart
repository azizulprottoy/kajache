import 'package:get/get.dart';

import '../controllers/reword_controller.dart';
import '../repository/reword_repository.dart';

class RewardsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RewordRepository>(() => RewordRepository(), fenix: true);
    Get.lazyPut<RewardsController>(
      () => RewardsController(rewordRepository: Get.find<RewordRepository>()),
      fenix: true,
    );
  }
}