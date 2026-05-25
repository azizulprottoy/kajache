import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/common_app_bar.dart';
import '../controllers/profile_controller.dart';
import 'edit_profile_page.dart';

class MyProfilePage extends GetView<ProfileController> {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CommonAppBar(
        title: 'my_profile',
        showBack: true,
        showLanguageToggle: true,
      ),
      body: Obx(
            () => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: colorScheme.primary.withOpacity(0.12),
                      child: Icon(
                        Icons.person,
                        size: 42,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      controller.isBuyer
                          ? controller.fullNameController.text
                          : controller.businessNameController.text,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.isBuyer ? 'Buyer Account' : 'Service Provider',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          Get.to(
                                () => const EditProfilePage(),
                            arguments: controller.profileType.value,
                          );
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit Profile'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ProfileSection(
                title: 'Basic Information',
                children: [
                  _InfoRow(
                    label: 'Full Name',
                    value: controller.fullNameController.text,
                  ),
                  _InfoRow(
                    label: 'Email',
                    value: controller.emailController.text,
                  ),
                  _InfoRow(
                    label: 'Phone',
                    value: controller.phoneController.text,
                  ),
                  _InfoRow(
                    label: 'Address',
                    value: controller.addressController.text,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (controller.isBuyer)
                const _ProfileSection(
                  title: 'Buyer Details',
                  children: [
                    _InfoRow(label: 'Total Orders', value: '24'),
                    _InfoRow(label: 'Completed Orders', value: '20'),
                    _InfoRow(label: 'Saved Services', value: '8'),
                  ],
                ),
              if (controller.isServiceProvider)
                _ProfileSection(
                  title: 'Service Provider Details',
                  children: [
                    _InfoRow(
                      label: 'Business Name',
                      value: controller.businessNameController.text,
                    ),
                    _InfoRow(
                      label: 'Category',
                      value: controller.categoryController.text,
                    ),
                    _InfoRow(
                      label: 'Experience',
                      value: controller.experienceController.text,
                    ),
                    _InfoRow(
                      label: 'Service Area',
                      value: controller.serviceAreaController.text,
                    ),
                    const _InfoRow(label: 'Rating', value: '4.8'),
                    const _InfoRow(label: 'Completed Jobs', value: '136'),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ProfileSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}