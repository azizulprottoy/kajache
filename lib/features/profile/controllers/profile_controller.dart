import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../models/profile_model.dart';
import '../models/worker_profile_model.dart';
import '../repository/profile_repository.dart';

class ProfileController extends GetxController {
  final ProfileRepository _repository = ProfileRepository();
  final ImagePicker _picker = ImagePicker();

  final Rx<ProfileType> profileType = ProfileType.buyer.obs;
  final Rxn<ProfileModel> profile = Rxn<ProfileModel>();
  final Rxn<File> avatarFile = Rxn<File>();

  final formKey = GlobalKey<FormState>();
  final RxBool isLoading = false.obs;

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

  final selectedDistrict = RxnString();
  final selectedArea = RxnString();

  final districts = <String>[
    'Bagerhat', 'Bandarban', 'Barguna', 'Barishal', 'Bhola', 'Bogura',
    'Brahmanbaria', 'Chandpur', 'Chattogram', 'Chuadanga', "Cox's Bazar",
    'Cumilla', 'Dhaka', 'Dinajpur', 'Faridpur', 'Feni', 'Gaibandha',
    'Gazipur', 'Gopalganj', 'Habiganj', 'Jamalpur', 'Jashore', 'Jhalokati',
    'Jhenaidah', 'Joypurhat', 'Khagrachhari', 'Khulna', 'Kishoreganj',
    'Kurigram', 'Kushtia', 'Lakshmipur', 'Lalmonirhat', 'Madaripur', 'Magura',
    'Manikganj', 'Meherpur', 'Moulvibazar', 'Munshiganj', 'Mymensingh',
    'Naogaon', 'Narail', 'Narayanganj', 'Narsingdi', 'Natore',
    'Chapainawabganj', 'Netrokona', 'Nilphamari', 'Noakhali', 'Pabna',
    'Panchagarh', 'Patuakhali', 'Pirojpur', 'Rajbari', 'Rajshahi',
    'Rangamati', 'Rangpur', 'Satkhira', 'Shariatpur', 'Sherpur', 'Sirajganj',
    'Sunamganj', 'Sylhet', 'Tangail', 'Thakurgaon',
  ].obs;

  final Map<String, List<String>> areasByDistrict = {
    'Dhaka': ['Dhanmondi', 'Gulshan', 'Mirpur', 'Uttara', 'Mohammadpur', 'Banani', 'Motijheel'],
    'Chattogram': ['Agrabad', 'Pahartali', 'Halishahar', 'Nasirabad', 'Khulshi'],
    'Sylhet': ['Zindabazar', 'Ambarkhana', 'Subid Bazar', 'Tilagor'],
    // ...populate the rest, or fetch from backend
  };

  List<String> get currentAreas => selectedDistrict.value == null
      ? <String>[]
      : (areasByDistrict[selectedDistrict.value] ?? <String>[]);

  void onDistrictSelected(String district) {
    selectedDistrict.value = district;
    selectedArea.value = null;
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
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  Future<void> fetchMyProfile() async {
    try {
      isLoading.value = true;

      final p = await _repository.getMyProfile();
      profile.value = p;

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

      if (p.district.isNotEmpty) selectedDistrict.value = p.district;
      if (p.area.isNotEmpty) selectedArea.value = p.area;
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
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
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
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
