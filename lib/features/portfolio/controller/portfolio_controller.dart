import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../profile/models/profile_model.dart';
import '../../profile/repository/profile_repository.dart';
import '../model/portfolio_model.dart';
import '../repository/portfolio_repository.dart';

class PortfolioController extends GetxController {
  final PortfolioRepository _repository;
  final ProfileRepository _profileRepository;
  final ImagePicker _imagePicker;

  PortfolioController({
    PortfolioRepository? repository,
    ProfileRepository? profileRepository,
    ImagePicker? imagePicker,
  })  : _repository = repository ?? PortfolioRepository(),
        _profileRepository = profileRepository ?? ProfileRepository(),
        _imagePicker = imagePicker ?? ImagePicker();

  final portfolioItems = <PortfolioItem>[].obs;
  final profile = Rxn<ProfileModel>();
  final selectedImage = Rxn<File>();

  final isLoading = false.obs;
  final isSaving = false.obs;
  final deletingId = ''.obs;
  final errorMessage = ''.obs;

  final formKey = GlobalKey<FormState>();
  final serviceDetailsController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadPortfolio();
  }

  Future<void> loadPortfolio() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final results = await Future.wait<dynamic>([
        _profileRepository.getMyProfile(),
        _repository.getPortfolios(),
      ]);

      final currentProfile = results[0] as ProfileModel;
      final portfolios = results[1] as List<PortfolioItem>;

      profile.value = currentProfile;
      portfolioItems.assignAll(
        portfolios.where(
          (item) => item.technitianId == currentProfile.id,
        ),
      );
    } catch (error) {
      errorMessage.value = _cleanError(error);
    } finally {
      isLoading.value = false;
    }
  }

  void prepareCreate() {
    serviceDetailsController.clear();
    selectedImage.value = null;
  }

  void prepareEdit(PortfolioItem item) {
    serviceDetailsController.text = item.servicedetails;
    selectedImage.value = null;
  }

  Future<void> pickImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1600,
    );

    if (picked != null) {
      selectedImage.value = File(picked.path);
    }
  }

  Future<bool> createPortfolio() async {
    if (!(formKey.currentState?.validate() ?? false)) return false;

    final currentProfile = profile.value;
    if (currentProfile == null || currentProfile.id.isEmpty) {
      Get.snackbar(
        'Unable to save',
        'Technician profile information is missing.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final image = selectedImage.value;
    if (image == null) {
      Get.snackbar(
        'Image required',
        'Please select a portfolio image.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    try {
      isSaving.value = true;
      final item = await _repository.createPortfolio(
        technitianId: currentProfile.id,
        technitianName: currentProfile.fullName,
        image: image,
        servicedetails: serviceDetailsController.text.trim(),
      );
      portfolioItems.insert(0, item);
      Get.snackbar(
        'Success',
        'Portfolio work added successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (error) {
      Get.snackbar(
        'Error',
        _cleanError(error),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updatePortfolio(PortfolioItem original) async {
    if (!(formKey.currentState?.validate() ?? false)) return false;

    final currentProfile = profile.value;
    if (currentProfile == null || currentProfile.id.isEmpty) {
      Get.snackbar(
        'Unable to save',
        'Technician profile information is missing.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    try {
      isSaving.value = true;
      final updated = await _repository.updatePortfolio(
        portfolio: original,
        technitianId: currentProfile.id,
        technitianName: currentProfile.fullName,
        servicedetails: serviceDetailsController.text.trim(),
        image: selectedImage.value,
      );

      final index = portfolioItems.indexWhere((item) => item.id == original.id);
      if (index >= 0) portfolioItems[index] = updated;

      Get.snackbar(
        'Success',
        'Portfolio work updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (error) {
      Get.snackbar(
        'Error',
        _cleanError(error),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deletePortfolio(PortfolioItem item) async {
    try {
      deletingId.value = item.id;
      await _repository.deletePortfolio(item.id);
      portfolioItems.removeWhere((entry) => entry.id == item.id);
      Get.snackbar(
        'Deleted',
        'Portfolio work deleted successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Error',
        _cleanError(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      deletingId.value = '';
    }
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  void onClose() {
    serviceDetailsController.dispose();
    super.onClose();
  }
}
