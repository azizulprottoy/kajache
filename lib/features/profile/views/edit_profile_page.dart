import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/serachable_dropdown_field.dart';
import '../controllers/profile_controller.dart';

class EditProfilePage extends GetView<ProfileController> {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CommonAppBar(
        title: 'edit_profile',
        showBack: false,
        showLanguageToggle: true,
      ),
      body: Obx(
            () => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                Center(
                  child: GestureDetector(
                    onTap: controller.pickAvatar,
                    child: Stack(
                      children: [
                        Builder(builder: (_) {
                          final file = controller.avatarFile.value;
                          final url = controller.profile.value?.avatar ?? '';
                          ImageProvider? img;
                          if (file != null) {
                            img = FileImage(file);
                          } else if (url.isNotEmpty) {
                            img = NetworkImage(url);
                          }
                          return CircleAvatar(
                            radius: 46,
                            backgroundColor:
                            colorScheme.primary.withOpacity(0.12),
                            backgroundImage: img,
                            child: img == null
                                ? Icon(Icons.person,
                                size: 46, color: colorScheme.primary)
                                : null,
                          );
                        }),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: colorScheme.primary,
                            child: const Icon(Icons.edit,
                                size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                ProfileField(
                  controller: controller.fullNameController,
                  label: TKeys.fullname.tr,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 14),
                ProfileField(
                  controller: controller.emailController,
                  label: TKeys.email.tr,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                ProfileField(
                  controller: controller.phoneController,
                  label: TKeys.phone.tr,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),
                SearchableDropdownField(
                  label: TKeys.district.tr,
                  icon: Icons.map_outlined,
                  value: controller.selectedDistrict.value,
                  items: controller.districts,
                  hint: TKeys.selectDistrict.tr,
                  onSelected: controller.onDistrictSelected,
                ),
                const SizedBox(height: 14),
                SearchableDropdownField(
                  label: TKeys.area.tr,
                  icon: Icons.location_city_outlined,
                  value: controller.selectedArea.value,
                  items: controller.currentAreas,
                  enabled: controller.selectedDistrict.value != null,
                  hint: controller.selectedDistrict.value == null
                      ? TKeys.selectDistrictFirst.tr
                      : TKeys.selectArea.tr,
                  onSelected: controller.onAreaSelected,
                ),
                const SizedBox(height: 14),
                ProfileField(
                  controller: controller.addressController,
                  label: TKeys.address.tr,
                  icon: Icons.location_on_outlined,
                ),
                if (controller.isServiceProvider) ...[
                  const SizedBox(height: 14),
                  ProfileField(
                    controller: controller.businessNameController,
                    label: TKeys.businessName.tr,
                    icon: Icons.business_outlined,
                  ),
                  const SizedBox(height: 14),
                  SearchableDropdownField(
                    label: TKeys.serviceCategory.tr,
                    icon: Icons.miscellaneous_services_outlined,
                    value: controller.selectedCategory.value,
                    items: controller.categories,
                    enabled: !controller.isCategoriesLoading.value &&
                        controller.categories.isNotEmpty,
                    hint: controller.isCategoriesLoading.value
                        ? TKeys.loading.tr
                        : TKeys.serviceCategory.tr,
                    onSelected: controller.onCategorySelected,
                  ),
                  const SizedBox(height: 14),
                  ProfileField(
                    controller: controller.experienceController,
                    label: TKeys.experience.tr,
                    icon: Icons.workspace_premium_outlined,
                  ),
                  const SizedBox(height: 14),
                  ProfileField(
                    controller: controller.serviceAreaController,
                    label: TKeys.serviceArea.tr,
                    icon: Icons.map_outlined,
                  ),

                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.updateProfile,
                    child: controller.isLoading.value
                        ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(TKeys.saveChanges.tr),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
