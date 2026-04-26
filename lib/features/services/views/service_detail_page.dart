import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../controllers/services_details_controller.dart';

class ServiceDetailPage extends GetView<ServicesDetailsController> {
  const ServiceDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CommonAppBar(
        title: 'service_details',
        showLanguageToggle: true,
        showBack: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.popularServices.isEmpty) {
          return Center(
            child: Text(
              TKeys.noData.tr,
              style: theme.textTheme.bodyLarge,
            ),
          );
        }

        final service = controller.popularServices.first;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Service image/banner ─────────────────────────────────────
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.75),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.home_repair_service_rounded,
                  size: 72,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              // ── Title + category ────────────────────────────────────────
              Text(
                service.title.tr,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                service.category.tr,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 14),

              // ── Rating / reviews / price ────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${service.rating} (${service.reviews})',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '৳${service.price.toInt()}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Description ──────────────────────────────────────────────
              Text(
                'About Service',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This service is designed to help customers quickly and safely solve household problems with trusted professionals. You can book this service easily and get quality support at your preferred time.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),

              // ── Included features ────────────────────────────────────────
              Text(
                'What is included',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              const _FeatureTile(text: 'Professional service provider'),
              const _FeatureTile(text: 'Quick response and support'),
              const _FeatureTile(text: 'Affordable pricing'),
              const _FeatureTile(text: 'Trusted and verified service'),

              const SizedBox(height: 28),

              // ── Book button ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: TKeys.bookNow.tr,
                  variant: ButtonVariant.primary,
                  isFullWidth: true,
                  onPressed: () {
                    // TODO: navigate to booking page
                  },
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        );
      }),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final String text;

  const _FeatureTile({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.primary,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}