import 'package:get/get.dart';


import 'booking_details_controller.dart';
import 'booking_details_repository.dart';

class BookingDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingDetailsRepository>(() => BookingDetailsRepository());
    Get.lazyPut<BookingDetailsController>(() => BookingDetailsController());
  }
}
