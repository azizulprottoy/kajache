import 'package:get/get.dart';

import '../repository/recruitment_request_repository.dart';
import '../controller/my_recruitment_requests_controller.dart';

class MyRecruitmentRequestsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyRecruitmentRequestsController>(
      () => MyRecruitmentRequestsController(),
      fenix: true,
    );
    Get.lazyPut<RecruitmentRequestRepository>(
      () => RecruitmentRequestRepository(),
      fenix: true,
    );
  }
}
