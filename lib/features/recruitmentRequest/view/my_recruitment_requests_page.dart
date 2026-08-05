import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../controller/my_recruitment_requests_controller.dart';

class _StatusInfo {
  final String label;
  final Color color;
  const _StatusInfo(this.label, this.color);
}

_StatusInfo _statusInfoFor(String status) {
  switch (status.trim().toLowerCase()) {
    case 'pending_payment':
      return const _StatusInfo('Payment Pending', Colors.orange);
    case 'hiring_open':
      return const _StatusInfo('Hiring Open', Colors.blue);
    case 'hired':
      return const _StatusInfo('Hired', Colors.green);
    case 'ended':
      return _StatusInfo('Ended', Colors.grey.shade600);
    case 'cancelled':
      return const _StatusInfo('Cancelled', Colors.red);
    default:
      return _StatusInfo(status, Colors.grey);
  }
}

class MyRecruitmentRequestsPage extends GetView<MyRecruitmentRequestsController> {
  const MyRecruitmentRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: CommonAppBar(
        title: TKeys.myRecruitmentRequests.tr,
        showBack: false,
        showLanguageToggle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.recruitmentRequestPage),
        icon: const Icon(Icons.add),
        label: Text(TKeys.postRecruitmentRequest.tr),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.requests.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.fetchRequests,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.3),
                Icon(Icons.badge_outlined, size: 64, color: colorScheme.outline),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    TKeys.noJobPostsFound.tr,
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
          onRefresh: controller.fetchRequests,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: controller.requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final item = controller.requests[index];
              final statusInfo = _statusInfoFor(item.status);

              return Material(
                color: colorScheme.surface,
                elevation: 2,
                shadowColor: colorScheme.shadow.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Get.toNamed(
                    AppRoutes.myRecruitmentRequestDetails,
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
                            borderRadius:
                                const BorderRadius.vertical(top: Radius.circular(20)),
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
                                      Icons.badge_outlined,
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title.isEmpty ? 'Job Post' : item.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(fontWeight: FontWeight.w700),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          item.duration.isEmpty
                                              ? 'Duration not specified'
                                              : item.duration,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
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

                              Row(
                                children: [
                                  Expanded(
                                    child: _SummaryItem(
                                      label: TKeys.salaryLabel.tr,
                                      value: item.salaryLabel,
                                      icon: Icons.payments_outlined,
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 38,
                                    color: colorScheme.outlineVariant,
                                  ),
                                  Expanded(
                                    child: _SummaryItem(
                                      label: TKeys.applicantsLabel.tr,
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
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
  });

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
