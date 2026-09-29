import 'package:kaj_ache/core/error/api_error.dart';
import 'package:get/get.dart';

import '../../../core/utils/translation_keys.dart';
import '../model/recruitment_request_model.dart';
import '../repository/recruitment_request_repository.dart';

class MyRecruitmentRequestsController extends GetxController {
  final RecruitmentRequestRepository repository = RecruitmentRequestRepository();

  final isLoading = false.obs;
  final requests = <RecruitmentRequestModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    try {
      isLoading.value = true;
      final list = await repository.getMyRecruitmentRequests();
      requests.assignAll(list);
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
