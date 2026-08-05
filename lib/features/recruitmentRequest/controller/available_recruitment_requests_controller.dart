import 'package:get/get.dart';

import '../../../core/utils/translation_keys.dart';
import '../model/recruitment_request_model.dart';
import '../repository/recruitment_request_repository.dart';

/// Controller for the technician-facing "Job Openings" browse screen.
///
/// Tapping a posting fetches its full details (so we know `hasBid`/`myBid`
/// — the `available` list endpoint doesn't include those) and opens a
/// bottom sheet that doubles as the "view" and "apply/update application"
/// UI, mirroring the sbooking `_BidSheet` pattern.
class AvailableRecruitmentRequestsController extends GetxController {
  final RecruitmentRequestRepository repository = RecruitmentRequestRepository();

  final isLoading = false.obs;
  final availableRequests = <RecruitmentRequestModel>[].obs;

  final isLoadingDetails = false.obs;
  final isSubmittingBid = false.obs;
  final selectedRequest = Rxn<RecruitmentRequestDetailsModel>();

  @override
  void onInit() {
    super.onInit();
    fetchAvailableRequests();
  }

  Future<void> fetchAvailableRequests() async {
    try {
      isLoading.value = true;
      final list = await repository.getAvailableRecruitmentRequests();
      availableRequests.assignAll(list);
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

  Future<void> openRequest(String id) async {
    if (id.isEmpty) return;

    try {
      isLoadingDetails.value = true;
      selectedRequest.value = null;
      final detail = await repository.getRecruitmentRequest(id);
      selectedRequest.value = detail;
    } catch (e) {
      Get.snackbar(
        TKeys.error.tr,
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingDetails.value = false;
    }
  }

  void clearSelectedRequest() => selectedRequest.value = null;

  /// Places a new application, or updates the technician's existing one if
  /// they've already applied to this posting.
  Future<bool> submitBid({required num proposedSalary, String? message}) async {
    final current = selectedRequest.value;
    if (current == null || current.id.isEmpty) return false;
    if (isSubmittingBid.value) return false;

    try {
      isSubmittingBid.value = true;

      if (current.hasBid && current.myBid != null) {
        await repository.updateBid(
          current.id,
          current.myBid!.id,
          proposedSalary: proposedSalary,
          message: message,
        );
      } else {
        await repository.placeBid(
          current.id,
          proposedSalary: proposedSalary,
          message: message,
        );
      }

      // Refresh the detail (so `hasBid`/`myBid` reflect the new state) and
      // the list (bidsCount changes).
      final refreshed = await repository.getRecruitmentRequest(current.id);
      selectedRequest.value = refreshed;
      await fetchAvailableRequests();

      return true;
    } catch (e) {
      Get.snackbar(
        TKeys.error.tr,
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSubmittingBid.value = false;
    }
  }
}
