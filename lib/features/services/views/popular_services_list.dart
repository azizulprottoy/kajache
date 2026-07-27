import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaj_ache/features/service_details/arguments/service_details_arguments.dart';

import '../../../shared/shimmers/popular_services_shimmer.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../home/models/services_response_model.dart';
import '../arguments/service_argument.dart';

class PopularServicesList extends StatelessWidget {
  final List<ServiceModel> services;
  final bool isLoading;

  const PopularServicesList({
    super.key,
    required this.services,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoading && services.isEmpty) {
      return const PopularServicesShimmer();
    }

    if (services.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            'No services available',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final service = services[index];

        return GestureDetector(
          onTap: () => Get.toNamed(
            AppRoutes.serviceDetails,
            arguments: ServiceDetailsArgument(serviceSlug: service.slug

            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colorScheme.outlineVariant.withOpacity(0.1),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: service.imageLink.isNotEmpty
                      ? Image.network(
                          service.imageLink,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.home_repair_service_outlined,
                            color: colorScheme.primary,
                          ),
                        )
                      : Icon(
                          Icons.home_repair_service_outlined,
                          color: colorScheme.primary,
                        ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.localizedTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.localizedDescription,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
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
                        '৳${service.basePrice.toInt()}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      // const SizedBox(height: 8),
                      // CustomButton(
                      //   label: TKeys.bookNow.tr,
                      //   variant: ButtonVariant.primary,
                      //   size: ButtonSize.sm,
                      //   isFullWidth: true,
                      //   onPressed: () {
                      //     Get.toNamed(
                      //       AppRoutes.bookingPage,
                      //       arguments: service,
                      //     );
                      //   },
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}