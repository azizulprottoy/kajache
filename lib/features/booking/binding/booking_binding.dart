import 'package:get/get.dart';
import 'package:kaj_ache/features/booking/repository/booking_repository.dart';
import '../controller/booking_controller.dart';

class BookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingController>(() => BookingController(), fenix: true);
    Get.lazyPut<BookingRepository>(() => BookingRepository(), fenix: true);

  }
}