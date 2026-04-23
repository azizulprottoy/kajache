import 'package:get/get.dart';

class MainController extends GetxController {
  final RxInt currentIndex = 1.obs;

  void changeNavIndex(int index) {
    currentIndex.value = index;
  }
}