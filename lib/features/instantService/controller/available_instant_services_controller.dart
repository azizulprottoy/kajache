import 'package:dio/dio.dart';
import 'package:kaj_ache/core/error/api_error.dart';
import 'package:get/get.dart';

import '../../../core/utils/translation_keys.dart';
import '../model/instant_service_model.dart';
import '../repository/instant_service_repository.dart';

/// Technician-side controller for browsing open instant services and
/// placing bids. Mirrors the pattern in
/// `lib/features/sbooking/booking_details_controller.dart` (submitBid /
/// isBidLoading) plus the accept step unique to Instant Service (the
/// selected bidder locks the job once the client has paid).
class AvailableInstantServicesController extends GetxController {
  final InstantServiceRepository repository = InstantServiceRepository();

  final isLoading = false.obs;
  final instantServices = <InstantServiceModel>[].obs;
  /// Jobs this technician was selected for, from waiting-for-payment through
  /// completed/cancelled (history).
  final myJobs = <InstantServiceModel>[].obs;

  final isLoadingDetails = false.obs;
  final isBidLoading = false.obs;
  final isAccepting = false.obs;
  final isSubmittingComplaint = false.obs;
  final selectedItem = Rxn<InstantServiceDetailsModel>();

  /// True while a job's details are fetched / its sheet is opening, so a
  /// double tap can't open two sheets.
  bool isOpeningSheet = false;

  /// Job to open right away, passed as `{'id': ...}` from the home page or a
  /// notification. Read once by the page.
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
    fetchAvailableInstantServices();
  }

  String? takeInitialId() {
    final id = _initialId;
    _initialId = null;
    return id;
  }

  Future<void> fetchAvailableInstantServices() async {
    try {
      isLoading.value = true;
      final results = await Future.wait([
        repository.getAvailableInstantServices(),
        repository.getMyInstantJobs(),
      ]);
      instantServices.assignAll(results[0]);
      myJobs.assignAll(results[1]);
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

  Future<void> openInstantService(String id) async {
    if (id.isEmpty) return;

    try {
      isLoadingDetails.value = true;
      selectedItem.value = await repository.getInstantService(id);
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

  Future<bool> submitBid({
    required int price,
    String? message,
    String? estimatedArrival,
  }) async {
    final current = selectedItem.value;
    if (current == null) return false;

    isBidLoading.value = true;
    try {
      if (current.hasBid && current.myBid != null) {
        await repository.updateBid(
          instantServiceId: current.id,
          bidId: current.myBid!.id,
          price: price,
          message: message,
          estimatedArrival: estimatedArrival,
        );
      } else {
        await repository.placeBid(
          instantServiceId: current.id,
          price: price,
          message: message,
          estimatedArrival: estimatedArrival,
        );
      }

      await openInstantService(current.id);
      await fetchAvailableInstantServices();
      return true;
    } catch (e) {
      Get.snackbar(
        TKeys.error.tr,
        apiErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isBidLoading.value = false;
    }
  }

  Future<bool> submitComplaint({required String title, required String reason}) async {
    final current = selectedItem.value;
    if (current == null || isSubmittingComplaint.value) return false;

    try {
      isSubmittingComplaint.value = true;
      await repository.submitComplaint(
        instantServiceId: current.id,
        title: title,
        reason: reason,
      );
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

  /// The selected technician locks the job once the client has paid.
  Future<bool> acceptJob() async {
    final current = selectedItem.value;
    if (current == null) return false;

    if (isAccepting.value) return false;

    try {
      isAccepting.value = true;
      await repository.acceptInstantService(current.id);
      await openInstantService(current.id);
      await fetchAvailableInstantServices();
      return true;
    } catch (e) {
      // The job changed first (e.g. cancelled): show its current state
      if (e is DioException && e.response?.statusCode == 409) openInstantService(current.id);
      Get.snackbar(
        TKeys.error.tr,
        apiErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isAccepting.value = false;
    }
  }
}
