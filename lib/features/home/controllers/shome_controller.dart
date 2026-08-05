import 'package:get/get.dart';

import '../../../core/utils/translation_keys.dart';
import '../models/available_booking_response_model.dart';
import '../repository/shome_repository.dart';
import '../../instantService/model/instant_service_model.dart';
import '../../instantService/repository/instant_service_repository.dart';
import '../../recruitmentRequest/model/recruitment_request_model.dart';
import '../../recruitmentRequest/repository/recruitment_request_repository.dart';

/// Controller for the technician (service-provider) home dashboard.
///
/// Data source: [SHomeRepository.getDashboard] →

class SHomeController extends GetxController {
  final SHomeRepository _repository = Get.find<SHomeRepository>();
  final _instantRepo = InstantServiceRepository();
  final _recruitRepo = RecruitmentRequestRepository();

  final RxBool isLoading = false.obs;
  final RxList<InstantServiceModel> instantServices = <InstantServiceModel>[].obs;
  final RxList<RecruitmentRequestModel> recruitmentRequests = <RecruitmentRequestModel>[].obs;


  final RxList<AvailableBookingModel> availableBookings =
      <AvailableBookingModel>[].obs;


  final RxInt newOrders = 0.obs;

  final RxInt activeBids = 0.obs;

  final RxInt ongoing = 0.obs;

  final RxInt completed = 0.obs;

  final RxString earnings = '৳0'.obs;

  final RxList<ServiceActivityModel> recentActivities =
      <ServiceActivityModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() {
    isLoading.value = true;

    _fetchInstantAndRecruitment();
    return _repository.getDashboard().then(_applyDashboard).catchError((error) {
      Get.snackbar(
        'error'.tr,
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }).whenComplete(() {
      isLoading.value = false;
    });
  }

  Future<void> _fetchInstantAndRecruitment() async {
    try {
      final results = await Future.wait([
        _instantRepo.getAvailableInstantServices(),
        _recruitRepo.getAvailableRecruitmentRequests(),
      ]);
      if (!isClosed) {
        instantServices.assignAll(results[0] as List<InstantServiceModel>);
        recruitmentRequests.assignAll(results[1] as List<RecruitmentRequestModel>);
      }
    } catch (_) {}
  }

  void _applyDashboard(SHomeDashboardModel dashboard) {
    final stats = dashboard.stats;

    newOrders.value = stats.available;
    activeBids.value = stats.activeBids;
    ongoing.value = stats.ongoing;
    completed.value = stats.completed;
    earnings.value = '৳${_formatAmount(stats.earnings)}';

    availableBookings.assignAll(dashboard.availableJobs);

    recentActivities.assignAll(
      dashboard.availableJobs.take(5).map(
            (b) => ServiceActivityModel(
              title: '${b.serviceTitle} ${TKeys.request.tr}',
              subtitle:
                  '${TKeys.customer.tr}: ${b.clientName} • ${b.scheduleTime.isNotEmpty ? b.scheduleTime : b.scheduleDate}',
            ),
          ),
    );
  }

  String _formatAmount(int amount) {
    final digits = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i != 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}

class ServiceActivityModel {
  final String title;
  final String subtitle;

  ServiceActivityModel({
    required this.title,
    required this.subtitle,
  });
}
