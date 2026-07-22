import 'package:get/get.dart';
import '../../../core/utils/translation_keys.dart';

class PortfolioController extends GetxController {
  final RxList<PortfolioItem> portfolioItems = <PortfolioItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadPortfolio();
  }

  void loadPortfolio() {
    portfolioItems.assignAll([
      PortfolioItem(
        title: TKeys.pfBathroomCleaning.tr,
        subtitle: TKeys.pfBathroomCleaningDesc.tr,
      ),
      PortfolioItem(
        title: TKeys.pfKitchenPlumbing.tr,
        subtitle: TKeys.pfKitchenPlumbingDesc.tr,
      ),
      PortfolioItem(
        title: TKeys.pfWallPainting.tr,
        subtitle: TKeys.pfWallPaintingDesc.tr,
      ),
    ]);
  }
}

class PortfolioItem {
  final String title;
  final String subtitle;

  PortfolioItem({
    required this.title,
    required this.subtitle,
  });
}