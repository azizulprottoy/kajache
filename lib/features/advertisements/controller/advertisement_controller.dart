import 'package:get/get.dart';

import '../model/advertisement_model.dart';
import '../repository/advertisement_repository.dart';

class AdvertisementController extends GetxController {
  static AdvertisementController get to => Get.find();

  final _repository = AdvertisementRepository();

  final RxList<AdvertisementModel> _ads = <AdvertisementModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAds();
  }

  Future<void> fetchAds() async {
    isLoading.value = true;
    try {
      final list = await _repository.getAll();
      _ads.assignAll(list);
    } catch (_) {
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  List<AdvertisementModel> adsFor(String position) =>
      _ads.where((a) => a.position == position).toList()
        ..sort((a, b) => a.order.compareTo(b.order));

  void trackClick(String adId) => _repository.trackClick(adId);
}
