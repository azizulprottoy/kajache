import 'package:kaj_ache/core/error/api_error.dart';
import 'package:get/get.dart';

import '../../../core/utils/translation_keys.dart';
import '../model/recruitment_request_model.dart';
import '../repository/recruitment_request_repository.dart';

/// Technician's own recruitment applications (active, hired, not selected,
/// cancelled), so hire / end / cancel notifications have somewhere to land.
class MyApplicationsController extends GetxController {
  final RecruitmentRequestRepository repository = RecruitmentRequestRepository();

  final isLoading = false.obs;
  final applications = <RecruitmentApplicationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchApplications();
  }

  Future<void> fetchApplications() async {
    try {
      isLoading.value = true;
      applications.assignAll(await repository.getMyApplications());
    } catch (e) {
      Get.snackbar(
        TKeys.error.tr,
        apiErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
