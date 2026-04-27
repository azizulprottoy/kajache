import 'package:get/get.dart';

class SHomeController extends GetxController {
  final RxInt newOrders = 12.obs;
  final RxInt completedOrders = 8.obs;
  final RxInt pendingOrders = 4.obs;
  final RxString earnings = '৳4,200'.obs;

  final RxList<ServiceActivityModel> recentActivities =
      <ServiceActivityModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  void loadDashboardData() {
    recentActivities.assignAll([
      ServiceActivityModel(
        title: 'Bathroom cleaning booked',
        subtitle: 'Customer: Rahim Uddin • 10:30 AM',
      ),
      ServiceActivityModel(
        title: 'Electric repair completed',
        subtitle: 'Customer: Nusrat Jahan • 01:00 PM',
      ),
      ServiceActivityModel(
        title: 'Painting request received',
        subtitle: 'Customer: Karim Hasan • 03:15 PM',
      ),
    ]);
  }
}

class ServiceActivityModel {
  final String title;
  final String subtitle;

  ServiceActivityModel({
    required this.title,
    required this.subtitle,
  });
}