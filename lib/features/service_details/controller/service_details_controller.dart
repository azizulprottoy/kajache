import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../home/models/services_response_model.dart';
import '../arguments/service_details_arguments.dart';
import '../repository/service_details_repository.dart';

class ServiceDetailsController extends GetxController {
  final ServiceDetailsRepository _repository =
  Get.find<ServiceDetailsRepository>();
  late final String serviceSlug;
  bool isBooking = false;
  bool isProviderBidFlow = false;
  bool _hasInvalidArgument = false;
  final RxBool isLoading = false.obs;
  final Rxn<ServiceModel> service = Rxn<ServiceModel>();



  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is ServiceDetailsArgument && args.serviceSlug.isNotEmpty) {
      serviceSlug = args.serviceSlug;
      isBooking = args.isbooking ?? false;
      isProviderBidFlow = args.isProviderBidFlow ?? false;
    } else {
      _hasInvalidArgument = true;
    }
  }

  @override
  void onReady() {
    super.onReady();

    if (_hasInvalidArgument) {
      Get.back();

      Get.snackbar(
        'Error',
        'Service ID not found',
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    fetchServiceDetails();
  }

  Future<void> fetchServiceDetails() {
    final slug = serviceSlug;

    if (slug == null || slug.isEmpty) {
      return Future.value();
    }

    isLoading.value = true;

    return _repository
        .getServiceBySlug(slug)
        .then((data) {
      service.value = data;
    })
        .catchError((error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!isClosed) {
          Get.snackbar(
            'Error',
            error.toString().replaceFirst('Exception: ', ''),
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      });
    })
        .whenComplete(() {
      if (!isClosed) {
        isLoading.value = false;
      }
    });
  }
}