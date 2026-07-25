import 'package:get/get.dart';
import '../controller/portfolio_controller.dart';
import '../repository/portfolio_repository.dart';

class PortfolioBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PortfolioRepository>(
      () => PortfolioRepository(),
      fenix: true,
    );
    Get.lazyPut<PortfolioController>(
      () => PortfolioController(repository: Get.find<PortfolioRepository>()),
    );
  }
}
