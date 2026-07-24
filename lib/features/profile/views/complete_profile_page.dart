import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/serachable_dropdown_field.dart';
import '../controllers/profile_controller.dart';

class CompleteProfilePage extends GetView<ProfileController> {
  const CompleteProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CommonAppBar(
        title: TKeys.completeProfile.tr,
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
                    onPressed: controller.updateProfile,
                    child: Text(TKeys.saveProfile.tr),
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
