import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/translation_keys.dart';
import '../model/social_media_model.dart';
import '../repository/about_us_repository.dart';

class AboutUsController extends GetxController {
  final AboutUsRepository _repository = Get.find<AboutUsRepository>();

  final RxBool isLoading = false.obs;
  final RxList<SocialMediaModel> socialMedias = <SocialMediaModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      socialMedias.assignAll(await _repository.getSocialMedias());
    } catch (_) {
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  Future<void> refresh() => _load();

  Future<void> openLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar(
        TKeys.error.tr,
        TKeys.couldNotOpenLink.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
