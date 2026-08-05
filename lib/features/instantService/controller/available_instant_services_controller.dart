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

  final isLoadingDetails = false.obs;
  final isBidLoading = false.obs;
  final isAccepting = false.obs;
  final selectedItem = Rxn<InstantServiceDetailsModel>();

  @override
  void onInit() {
    super.onInit();
    fetchAvailableInstantServices();
  }

  Future<void> fetchAvailableInstantServices() async {
    try {
      isLoading.value = true;
      final list = await repository.getAvailableInstantServices();
      instantServices.assignAll(list);
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

  Future<void> openInstantService(String id) async {
    if (id.isEmpty) return;

    try {
      isLoadingDetails.value = true;
      selectedItem.value = await repository.getInstantService(id);
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
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isBidLoading.value = false;
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
      Get.snackbar(
        TKeys.error.tr,
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isAccepting.value = false;
    }
  }
}
