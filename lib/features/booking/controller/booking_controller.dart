import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaj_ache/app/routes/app_routes.dart';

class BookingController extends GetxController {
  final formKey = GlobalKey<FormState>();

  late TextEditingController dateController;
  late TextEditingController timeController;

  final RxBool isLoading = false.obs;
  final RxInt selectedAddressIndex = 0.obs;

  final RxString serviceTitle = ''.obs;
  final RxString serviceCategory = ''.obs;
  final RxDouble servicePrice = 0.0.obs;

  final RxList<AddressModel> addresses = <AddressModel>[
    AddressModel(
      title: 'Home',
      address: 'House 12, Road 5, Dhanmondi, Dhaka',
    ),
    AddressModel(
      title: 'Office',
      address: 'Level 7, Banani, Dhaka',
    ),
    AddressModel(
      title: 'Other',
      address: 'Mirpur DOHS, Dhaka',
    ),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    dateController = TextEditingController();
    timeController = TextEditingController();

    final args = Get.arguments;
    if (args is BookingArgument) {
      serviceTitle.value = args.title;
      serviceCategory.value = args.category;
      servicePrice.value = args.price;
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );

    if (picked != null) {
      dateController.text =
      '${picked.day.toString().padLeft(2, '0')}-'
          '${picked.month.toString().padLeft(2, '0')}-'
          '${picked.year}';
      update();
    }
  }

  Future<void> pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      timeController.text = picked.format(context);
      update();
    }
  }

  void selectAddress(int index) {
    selectedAddressIndex.value = index;
  }

  void addNewAddress() {
    Get.snackbar(
      'Add Address',
      'Add new address action tapped',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> proceed() async {
    if (!formKey.currentState!.validate()) return;

    if (addresses.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select an address',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 700));
    isLoading.value = false;

    Get.toNamed( AppRoutes.serviceDetails);
  }

  void cancel() {
    Get.back();
  }

  @override
  void onClose() {
    dateController.dispose();
    timeController.dispose();
    super.onClose();
  }
}

class AddressModel {
  final String title;
  final String address;

  AddressModel({
    required this.title,
    required this.address,
  });
}

class BookingArgument {
  final String title;
  final String category;
  final double price;

  BookingArgument({
    required this.title,
    required this.category,
    required this.price,
  });
}