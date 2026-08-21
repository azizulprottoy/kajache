import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../models/profile_model.dart';
import '../models/worker_profile_model.dart';
import '../../../core/network/geo_repository.dart';
import '../../../core/storage/local_storage_service.dart';
import '../repository/profile_repository.dart';

class ProfileController extends GetxController {
  final ProfileRepository _repository = ProfileRepository();
  final ImagePicker _picker = ImagePicker();

  final Rx<ProfileType> profileType = ProfileType.buyer.obs;
  final Rxn<ProfileModel> profile = Rxn<ProfileModel>();
  final Rxn<File> avatarFile = Rxn<File>();

  final formKey = GlobalKey<FormState>();
  final RxBool isLoading = true.obs;

  late TextEditingController fullNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  // Service provider fields
  late TextEditingController businessNameController;
  late TextEditingController experienceController;
  late TextEditingController serviceAreaController;

  final RxList<String> categories = <String>[].obs;
  final selectedCategory = RxnString();
  final RxBool isCategoriesLoading = false.obs;

  bool get isBuyer => profileType.value == ProfileType.buyer;
  bool get isServiceProvider =>
      profileType.value == ProfileType.serviceProvider;

  final _geoRepo = GeoRepository();

  final selectedDistrictId = RxnString();
  final selectedDistrict = RxnString();
  final selectedArea = RxnString();

  final RxList<GeoModel> districtList = <GeoModel>[].obs;
  final RxList<GeoModel> areaList = <GeoModel>[].obs;
  final RxBool isDistrictsLoading = false.obs;
  final RxBool isAreasLoading = false.obs;

  // Keep string list for backward compatibility with dropdowns
  List<String> get districts => districtList.map((d) => d.name).toList();
  List<String> get currentAreas => areaList.map((a) => a.name).toList();

  Future<void> fetchDistricts() async {
    isDistrictsLoading.value = true;
    try {
      districtList.assignAll(await _geoRepo.getDistricts());
    } catch (_) {
    } finally {
      if (!isClosed) isDistrictsLoading.value = false;
    }
  }

  Future<void> onDistrictSelected(String districtName) async {
    selectedDistrict.value = districtName;
    selectedArea.value = null;
    areaList.clear();
    final district = districtList.firstWhere(
      (d) => d.name == districtName,
      orElse: () => GeoModel(id: '', name: '', nameBn: ''),
    );
    if (district.id.isEmpty) return;
    selectedDistrictId.value = district.id;
    isAreasLoading.value = true;
    try {
      areaList.assignAll(await _geoRepo.getAreas(district.id));
    } catch (_) {
    } finally {
      if (!isClosed) isAreasLoading.value = false;
    }
  }

  void onAreaSelected(String area) => selectedArea.value = area;

  void onCategorySelected(String category) {
    selectedCategory.value = category;
  }

  @override
  void onInit() {
    super.onInit();

    fullNameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
    businessNameController = TextEditingController();
    experienceController = TextEditingController();
    serviceAreaController = TextEditingController();

    final args = Get.arguments;
    if (args is ProfileType) profileType.value = args;

    _loadProfileData();
    fetchDistricts();
  }

  Future<void> _loadProfileData() async {
    await fetchCategories();
    await fetchMyProfile();
  }

  Future<void> fetchCategories() async {
    try {
      isCategoriesLoading.value = true;
      categories.assignAll(await _repository.getCategoryNames());
    } catch (e) {
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  Future<void> fetchMyProfile() async {
    try {
      isLoading.value = true;

      final p = await _repository.getMyProfile();
      profile.value = p;

      // Cache avatar for use in comments/replies
      if (p.avatar.isNotEmpty) {
        Get.find<LocalStorageService>().write('user_avatar', p.avatar);
      }

      // Account type comes from the server (roleModelName)
      profileType.value = p.isServiceProvider
          ? ProfileType.serviceProvider
          : ProfileType.buyer;

      fullNameController.text = p.fullName;
      emailController.text = p.email;
      phoneController.text = p.phone;
      addressController.text = p.address;
      businessNameController.text = p.businessName;
      final savedCategory = p.category.trim();
      final matchingCategories = categories.where(
            (category) => category.toLowerCase() == savedCategory.toLowerCase(),
      );
      selectedCategory.value =
      matchingCategories.isEmpty ? null : matchingCategories.first;
      experienceController.text = p.experience;
      serviceAreaController.text = p.serviceArea;

      if (p.district.isNotEmpty) {
        selectedDistrict.value = p.district;
        // Load areas for the saved district
        final match = districtList.firstWhere(
          (d) => d.name == p.district,
          orElse: () => GeoModel(id: '', name: '', nameBn: ''),
        );
        if (match.id.isNotEmpty) {
          selectedDistrictId.value = match.id;
          areaList.assignAll(await _geoRepo.getAreas(match.id));
        }
      }
      if (p.area.isNotEmpty) selectedArea.value = p.area;
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickAvatar() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      avatarFile.value = File(picked.path);
    }
  }

  Future<void> updateProfile() async {
    if (!formKey.currentState!.validate()) return;

    if (selectedDistrict.value == null) {
      Get.snackbar('Missing', 'Please select a district',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (isServiceProvider && selectedCategory.value == null) {
      Get.snackbar('Missing', 'Please select a service category',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;

      final fields = <String, dynamic>{
        'fullName': fullNameController.text.trim(),
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'district': selectedDistrict.value,
        'area': selectedArea.value,
        if (isServiceProvider) ...{
          'businessName': businessNameController.text.trim(),
          'category': selectedCategory.value,
          'experience': experienceController.text.trim(),
          'serviceArea': serviceAreaController.text.trim(),
        },
      };

      await _repository.updateProfile(
        fields: fields,
        avatar: avatarFile.value,
      );

      Get.snackbar('Success', 'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM);

      await fetchMyProfile(); // refresh with saved values
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    businessNameController.dispose();
    experienceController.dispose();
    serviceAreaController.dispose();
    super.onClose();
  }
}
