import 'package:get/get.dart';

class SHomeController extends GetxController {
  final RxInt newOrders = 12.obs;
  final RxInt completedOrders = 8.obs;
  final RxInt pendingOrders = 4.obs;
  final RxString earnings = '৳4,200'.obs;

  final RxList<ServiceActivityModel> recentActivities =
      <ServiceActivityModel>[].obs;

  final RxList<BookedServiceModel> bookedServices =
      <BookedServiceModel>[].obs;

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

    bookedServices.assignAll([
      BookedServiceModel(
        title: 'Bathroom Cleaning',
        customerName: 'Rahim Uddin',
        date: '25 Apr 2026',
        time: '11:00 AM',
        status: 'Pending',
        price: '৳850',
      ),
      BookedServiceModel(
        title: 'Pipe Leak Fix',
        customerName: 'Nusrat Jahan',
        date: '25 Apr 2026',
        time: '02:30 PM',
        status: 'Accepted',
        price: '৳500',
      ),
      BookedServiceModel(
        title: 'Room Painting',
        customerName: 'Karim Hasan',
        date: '26 Apr 2026',
        time: '09:00 AM',
        status: 'Completed',
        price: '৳3000',
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

class BookedServiceModel {
  final String title;
  final String customerName;
  final String date;
  final String time;
  final String status;
  final String price;

  BookedServiceModel({
    required this.title,
    required this.customerName,
    required this.date,
    required this.time,
    required this.status,
    required this.price,
  });
}