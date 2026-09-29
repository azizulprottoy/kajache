import 'package:kaj_ache/core/error/api_error.dart';
import 'package:get/get.dart';

import '../../home/models/services_response_model.dart';
import '../repository/service_repository.dart';

class AllServicesController extends GetxController {
  final AllServicesRepository _repository = Get.find<AllServicesRepository>();

  final RxBool isLoading = false.obs;
  final RxList<ServiceModel> allServices = <ServiceModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllServices();
  }

  Future<void> fetchAllServices() {
    isLoading.value = true;

    return _repository
        .getAllServices()
        .then((services) {
      allServices.assignAll(services);
    })
        .catchError((error) {
      Get.snackbar(
        'error'.tr,
        apiErrorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    })
        .whenComplete(() {
      isLoading.value = false;
    });
  }

  void onServiceTap(ServiceModel service) {
    // You can handle navigation from UI or here.
  }
}