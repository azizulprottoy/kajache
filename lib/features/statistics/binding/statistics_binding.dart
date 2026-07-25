import 'package:get/get.dart';
import '../controller/statistics_controller.dart';
import '../repository/statistics_repository.dart';

class StatisticsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StatisticsRepository>(
      () => StatisticsRepository(),
      fenix: true,
    );
    Get.lazyPut<StatisticsController>(() => StatisticsController(), fenix: true);
  }
}
