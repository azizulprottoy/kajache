import 'package:get/get.dart';

import '../controller/my_booking_details_controller.dart';



class MyBookingDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyBookingDetailsController>(
          () => MyBookingDetailsController(),
    );
  }
}