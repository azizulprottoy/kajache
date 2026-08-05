import 'package:get/get.dart';

import '../repository/recruitment_request_repository.dart';
import '../controller/available_recruitment_requests_controller.dart';

class AvailableRecruitmentRequestsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AvailableRecruitmentRequestsController>(
      () => AvailableRecruitmentRequestsController(),
      fenix: true,
    );
    Get.lazyPut<RecruitmentRequestRepository>(
      () => RecruitmentRequestRepository(),
      fenix: true,
    );
  }
}
