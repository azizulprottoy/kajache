import 'package:get/get.dart';
import '../controller/terms_controller.dart';

class TermsConditionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TermsConditionController>(
          () => TermsConditionController(),
      fenix: true,
    );
  }
}