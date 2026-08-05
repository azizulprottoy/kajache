import 'package:get/get.dart';

import '../../../core/utils/translation_keys.dart';
import '../model/instant_service_model.dart';
import '../repository/instant_service_repository.dart';

/// Controller for the customer's own instant-service list.
/// Mirrors `lib/features/my_bookings/controller/my_booking_controller.dart`.
class MyInstantServicesController extends GetxController {
  final InstantServiceRepository repository = InstantServiceRepository();

  final isLoading = false.obs;
  final instantServices = <InstantServiceModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchInstantServices();
  }

  Future<void> fetchInstantServices() async {
    try {
      isLoading.value = true;
      final list = await repository.getMyInstantServices();
      instantServices.assignAll(list);
    } catch (e) {
      Get.snackbar(
        TKeys.error.tr,
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
