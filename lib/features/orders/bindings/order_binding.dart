import 'package:get/get.dart';
import '../controllers/order_controller.dart';

class PreviousOrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PreviousOrdersController>(
          () => PreviousOrdersController(),
      fenix: true,
    );
  }
}