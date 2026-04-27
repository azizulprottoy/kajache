import 'package:get/get.dart';

class StatisticsController extends GetxController {
  final RxInt totalJobs = 138.obs;
  final RxInt completedJobs = 126.obs;
  final RxInt cancelledJobs = 5.obs;
  final RxDouble rating = 4.8.obs;
}