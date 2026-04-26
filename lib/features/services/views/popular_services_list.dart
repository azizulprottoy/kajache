import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../home/controllers/home_controller.dart';
import '../arguments/service_argument.dart';


class PopularServicesList extends GetView<HomeController> {
  const PopularServicesList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme       = Theme.of(context);

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.popularServices.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final service = controller.popularServices[index];
          return GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.serviceDetails,  arguments:  ServiceArgument(
                ServiceID:'20'
            )),            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.home_repair_service_outlined,
                        color: AppColors.primary, size: 32),
                  ),
                  const SizedBox(width: 12),

                  // ── Info ───────────────────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.title.tr,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary ,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          service.category.tr,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.textPrimary ,                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.star_rounded,
                                size: 14, color: Colors.amber.shade600),
                            const SizedBox(width: 2),
                            Text(
                              service.rating.toString(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary ,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${service.reviews})',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.primary ,                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    width: 90,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '৳${service.price.toInt()}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomButton(
                          label: TKeys.bookNow.tr,
                          variant: ButtonVariant.primary,

                          size: ButtonSize.sm,
                          isFullWidth: true,
                        ),
                      ],
                    ),
                  ),                ],
              ),
            ),
          );
        },
      );
    });
  }
}