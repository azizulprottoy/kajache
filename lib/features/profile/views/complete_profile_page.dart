import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/common_app_bar.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../controllers/profile_controller.dart';

class CompleteProfilePage extends GetView<ProfileController> {
  const CompleteProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CommonAppBar(
        title: 'Complete Profile',
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
                    onPressed: controller.saveProfile,
                    child: const Text('Save Profile'),
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