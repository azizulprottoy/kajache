import 'package:kaj_ache/core/error/api_error.dart';
import 'package:get/get.dart';

import '../../../core/utils/translation_keys.dart';
import '../model/recruitment_request_model.dart';
import '../repository/recruitment_request_repository.dart';

/// Controller for the technician-facing "Job Openings" browse screen.
///
/// Tapping a posting fetches its full details (bids, own application) and
/// opens a
/// bottom sheet that doubles as the "view" and "apply/update application"
/// UI, mirroring the sbooking `_BidSheet` pattern.
class AvailableRecruitmentRequestsController extends GetxController {
  final RecruitmentRequestRepository repository = RecruitmentRequestRepository();

  final isLoading = false.obs;
  final availableRequests = <RecruitmentRequestModel>[].obs;

  final isLoadingDetails = false.obs;
  final isSubmittingBid = false.obs;
  final isSubmittingComplaint = false.obs;
  final selectedRequest = Rxn<RecruitmentRequestDetailsModel>();

  /// True while a post's details are fetched / its sheet is opening, so a
  /// double tap can't open two sheets.
  bool isOpeningSheet = false;

  /// Post to open right away, passed as `{'id': ...}` (home tile,
  /// notification, My applications). Read once by the page.
  String? _initialId;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments is Map) {
      final id = arguments['id']?.toString().trim() ?? '';
      if (id.isNotEmpty) _initialId = id;
    } else if (arguments is String && arguments.trim().isNotEmpty) {
      _initialId = arguments.trim();
    }
    fetchAvailableRequests();
  }

  String? takeInitialId() {
    final id = _initialId;
    _initialId = null;
    return id;
  }

  Future<bool> submitComplaint({required String title, required String reason}) async {
    final current = selectedRequest.value;
    if (current == null || isSubmittingComplaint.value) return false;

    try {
      isSubmittingComplaint.value = true;
      await repository.submitComplaint(current.id, title: title, reason: reason);
      return true;
    } catch (e) {
      Get.snackbar(
        TKeys.error.tr,
        apiErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSubmittingComplaint.value = false;
    }
  }

  Future<void> fetchAvailableRequests() async {
    try {
      isLoading.value = true;
      final list = await repository.getAvailableRecruitmentRequests();
      availableRequests.assignAll(list);
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
        apiErrorMessage(e),
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
        apiErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSubmittingBid.value = false;
    }
  }
}
