import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../../../shared/shimmers/profile_shimmer.dart';
import '../../advertisements/widget/ad_banner.dart';
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
        showBack: false,
        showLanguageToggle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.profile.value == null) {
          return const ProfileShimmer();
        }

        final avatar = controller.profile.value?.avatar ?? '';

        return RefreshIndicator(
          onRefresh: controller.fetchMyProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                        backgroundImage:
                        avatar.isNotEmpty ? NetworkImage(avatar) : null,
                        child: avatar.isEmpty
                            ? Icon(Icons.person,
                            size: 42, color: colorScheme.primary)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        controller.isBuyer
                            ? controller.fullNameController.text
                            : (controller.businessNameController.text.isNotEmpty
                            ? controller.businessNameController.text
                            : controller.fullNameController.text),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.isBuyer
                            ? TKeys.buyerAccount.tr
                            : TKeys.serviceProvider.tr,
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
                          label: Text(TKeys.editProfile.tr),
                        ),
                      ),
                    ],
                  ),
                ),
                AdBanner(position: 'profile_middle', height: 100, padding: EdgeInsets.symmetric(vertical: 12)),

                const SizedBox(height: 16),
                _ProfileSection(
                  title: TKeys.basicInformation.tr,
                  children: [
                    _InfoRow(
                        label: TKeys.fullname.tr,
                        value: controller.fullNameController.text),
                    _InfoRow(
                        label: TKeys.email.tr,
                        value: controller.emailController.text),
                    _InfoRow(
                        label: TKeys.phone.tr,
                        value: controller.phoneController.text),
                    _InfoRow(
                        label: TKeys.address.tr,
                        value: controller.addressController.text),
                  ],
                ),
                const SizedBox(height: 16),
                if (controller.isBuyer)
                  _ProfileSection(
                    title: TKeys.buyerDetails.tr,
                    children: [
                      _InfoRow(
                        label: TKeys.jobsPosted.tr,
                        value: '${controller.profile.value?.jobPostCount ?? 0}',
                      ),
                      _InfoRow(
                        label: TKeys.totalSpent.tr,
                        value: '৳${controller.profile.value?.totalSpent ?? 0}',
                      ),
                      _InfoRow(
                        label: TKeys.trustScore.tr,
                        value: '${controller.profile.value?.trustScore ?? 0}',
                      ),
                    ],
                  ),
                if (controller.isServiceProvider)
                  _ProfileSection(
                    title: TKeys.serviceProviderDetails.tr,
                    children: [
                      _InfoRow(
                          label: TKeys.businessName.tr,
                          value: controller.businessNameController.text),
                      _InfoRow(
                          label: TKeys.category.tr,
                          value: controller.selectedCategory.value ?? ''),
                      _InfoRow(
                          label: TKeys.experience.tr,
                          value: controller.experienceController.text),
                      _InfoRow(
                          label: TKeys.serviceArea.tr,
                          value: controller.serviceAreaController.text),
                      _InfoRow(
                        label: TKeys.rating.tr,
                        value: '${controller.profile.value?.rating ?? 0}',
                      ),
                      _InfoRow(
                        label: TKeys.completedJobs.tr,
                        value:
                        '${controller.profile.value?.totalJobsCompleted ?? 0}',
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ProfileSection({required this.title, required this.children});

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

  const _InfoRow({required this.label, required this.value});

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
              value.isEmpty ? '—' : value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
