import 'package:get/get.dart';

class PreviousOrdersController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<PreviousOrderModel> previousOrders = <PreviousOrderModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  void loadOrders() {
    previousOrders.assignAll([
      PreviousOrderModel(
        serviceName: 'Pipe Leak Fix',
        category: 'Plumbing',
        date: '15 Mar 2026',
        price: 500,
        status: 'Completed',
        rating: 4.8,
      ),
      PreviousOrderModel(
        serviceName: 'Bathroom Cleaning',
        category: 'Cleaning',
        date: '08 Mar 2026',
        price: 800,
        status: 'Completed',
        rating: 4.6,
      ),
      PreviousOrderModel(
        serviceName: 'Stove Repair',
        category: 'Kitchen',
        date: '02 Mar 2026',
        price: 450,
        status: 'Completed',
        rating: 4.7,
      ),
    ]);
  }
}

class PreviousOrderModel {
  final String serviceName;
  final String category;
  final String date;
  final double price;
  final String status;
  final double rating;

  PreviousOrderModel({
    required this.serviceName,
    required this.category,
    required this.date,
    required this.price,
    required this.status,
    required this.rating,
  });
}