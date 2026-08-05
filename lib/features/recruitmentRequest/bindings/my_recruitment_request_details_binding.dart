import 'package:get/get.dart';

import '../repository/recruitment_request_repository.dart';
import '../controller/my_recruitment_request_details_controller.dart';

class MyRecruitmentRequestDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyRecruitmentRequestDetailsController>(
      () => MyRecruitmentRequestDetailsController(),
      fenix: true,
    );
    Get.lazyPut<RecruitmentRequestRepository>(
      () => RecruitmentRequestRepository(),
      fenix: true,
    );
  }
}
