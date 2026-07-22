import 'package:get/get.dart';

import '../../../core/utils/translation_keys.dart';
import '../models/available_booking_response_model.dart';
import '../repository/shome_repository.dart';

/// Controller for the technician (service-provider) home dashboard.
///
/// Data source: [SHomeRepository.getDashboard] →
/// GET /api/v1/booking/provider/dashboard, which returns the overview stats
/// and the list of open jobs the technician can bid on.
class SHomeController extends GetxController {
  final SHomeRepository _repository = Get.find<SHomeRepository>();

  final RxBool isLoading = false.obs;

  /// Open jobs the technician is eligible to bid on.
  final RxList<AvailableBookingModel> availableBookings =
      <AvailableBookingModel>[].obs;

  // ── Overview metrics (from the backend dashboard) ───────────────────────────
  /// Open jobs available to bid on right now.
  final RxInt newOrders = 0.obs;

  /// Bids awaiting the client's decision.
  final RxInt activeBids = 0.obs;

  /// Won jobs currently in progress (bid_selected / in_progress).
  final RxInt ongoing = 0.obs;

  /// Jobs completed by this technician.
  final RxInt completed = 0.obs;

  /// Lifetime earnings from completed jobs, e.g. "৳4,200".
  final RxString earnings = '৳0'.obs;

  /// Latest few jobs, surfaced as a lightweight activity feed.
  final RxList<ServiceActivityModel> recentActivities =
      <ServiceActivityModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() {
    isLoading.value = true;

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

  /// Formats an integer with thousands separators (e.g. 4200 → "4,200").
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

/// Lightweight activity-feed item shown on the technician dashboard.
class ServiceActivityModel {
  final String title;
  final String subtitle;

  ServiceActivityModel({
    required this.title,
    required this.subtitle,
  });
}
