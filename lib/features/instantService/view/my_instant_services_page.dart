import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/booking_status_helper.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../controller/my_instant_services_controller.dart';
import '../model/instant_service_model.dart';

/// The customer's own instant services list.
/// Mirrors `lib/features/my_bookings/view/my_bookings_page.dart`.
class MyInstantServicesPage extends GetView<MyInstantServicesController> {
  const MyInstantServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: CommonAppBar(
        title: TKeys.myInstantServices.tr,
        showBack: false,
        showLanguageToggle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.instantServicePage),
        icon: const Icon(Icons.bolt_outlined),
        label: Text(TKeys.postInstantService.tr),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.instantServices.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.fetchInstantServices,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.3),
                Icon(
                  Icons.bolt_outlined,
                  size: 64,
                  color: colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    TKeys.noInstantServicesFound.tr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchInstantServices,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: controller.instantServices.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final item = controller.instantServices[index];
              final statusInfo = BookingStatusHelper.of(item.status);

              return Material(
                color: colorScheme.surface,
                elevation: 2,
                shadowColor: colorScheme.shadow.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Get.toNamed(
                    AppRoutes.myInstantServiceDetails,
                    arguments: item.id,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.65),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 5,
                          decoration: BoxDecoration(
                            color: statusInfo.color,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      Icons.bolt_outlined,
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title.isEmpty ? TKeys.untitledService.tr : item.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          '#${_shortId(item.id)}',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: statusInfo.color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text(
                                      statusInfo.label,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: statusInfo.color,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (item.details.trim().isNotEmpty) ...[
                                const SizedBox(height: 14),
                                Text(
                                  item.details,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    height: 1.45,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              Divider(height: 1, color: colorScheme.outlineVariant),
                              const SizedBox(height: 14),
                              _InformationRow(
                                icon: Icons.location_on_outlined,
                                text: _locationText(item.location),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _SummaryItem(
                                      label: TKeys.jobBudget.tr,
                                      value: item.priceRangeLabel,
                                      icon: Icons.payments_outlined,
                                    ),
                                  ),
                                  Container(width: 1, height: 38, color: colorScheme.outlineVariant),
                                  Expanded(
                                    child: _SummaryItem(
                                      label: TKeys.bids.tr,
                                      value: '${item.bidsCount}',
                                      icon: Icons.people_alt_outlined,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                    color: colorScheme.primary,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  static String _shortId(String id) {
    if (id.length <= 8) return id.toUpperCase();
    return id.substring(id.length - 8).toUpperCase();
  }

  static String _locationText(InstantServiceLocationModel location) {
    return [location.address, location.city]
        .where((value) => value.trim().isNotEmpty)
        .join(', ');
  }
}

class _InformationRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InformationRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: colorScheme.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text.isEmpty ? 'Not specified' : text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
