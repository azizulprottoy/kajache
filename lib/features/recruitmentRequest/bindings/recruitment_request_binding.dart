import 'package:get/get.dart';

import '../repository/recruitment_request_repository.dart';
import '../controller/recruitment_request_controller.dart';

class RecruitmentRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RecruitmentRequestController>(
      () => RecruitmentRequestController(),
      fenix: true,
    );
    Get.lazyPut<RecruitmentRequestRepository>(
      () => RecruitmentRequestRepository(),
      fenix: true,
    );
  }
}
