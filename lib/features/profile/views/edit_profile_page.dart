import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/common_app_bar.dart';
import '../../../shared/widgets/custom_text_field.dart';
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
        showBack: true,
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
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: colorScheme.primary.withOpacity(0.12),
                        child: Icon(
                          Icons.person,
                          size: 46,
                          color: colorScheme.primary,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: colorScheme.primary,
                          child: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ProfileField(
                  controller: controller.fullNameController,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 14),
                ProfileField(
                  controller: controller.emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                ProfileField(
                  controller: controller.phoneController,
                  label: 'Phone',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),
                ProfileField(
                  controller: controller.addressController,
                  label: 'Address',
                  icon: Icons.location_on_outlined,
                ),
                if (controller.isServiceProvider) ...[
                  const SizedBox(height: 14),
                  ProfileField(
                    controller: controller.businessNameController,
                    label: 'Business Name',
                    icon: Icons.business_outlined,
                  ),
                  const SizedBox(height: 14),
                  ProfileField(
                    controller: controller.categoryController,
                    label: 'Service Category',
                    icon: Icons.miscellaneous_services_outlined,
                  ),
                  const SizedBox(height: 14),
                  ProfileField(
                    controller: controller.experienceController,
                    label: 'Experience',
                    icon: Icons.workspace_premium_outlined,
                  ),
                  const SizedBox(height: 14),
                  ProfileField(
                    controller: controller.serviceAreaController,
                    label: 'Service Area',
                    icon: Icons.map_outlined,
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: controller.updateProfile,
                    child: const Text('Save Changes'),
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