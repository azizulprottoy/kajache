import 'package:get/get.dart';
import '../controller/csupport_controller.dart';
import '../repository/csupport_repository.dart';

class CustomerSupportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CsupportRepository>(() => CsupportRepository(), fenix: true);
    Get.lazyPut<CustomerSupportController>(
      () => CustomerSupportController(),
      fenix: true,
    );
  }
}
