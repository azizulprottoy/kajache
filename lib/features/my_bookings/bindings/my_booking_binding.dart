import 'package:get/get.dart';
import 'package:kaj_ache/features/my_bookings/controller/my_booking_controller.dart';
import 'package:kaj_ache/features/my_bookings/repository/my_booking_repository.dart';

class MyBookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyBookingController>(() => MyBookingController(), fenix: true);
    Get.lazyPut<MyBookingRepository>(() => MyBookingRepository(), fenix: true);

  }
}