import 'package:get/get.dart';

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
        title: 'Bathroom Deep Cleaning',
        subtitle: 'Completed for a residential apartment',
      ),
      PortfolioItem(
        title: 'Kitchen Plumbing Repair',
        subtitle: 'Pipe leakage fixed successfully',
      ),
      PortfolioItem(
        title: 'Wall Painting Service',
        subtitle: 'Full room repaint completed',
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