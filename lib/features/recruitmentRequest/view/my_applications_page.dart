import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/context_extension.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/booking_status_helper.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../controller/my_applications_controller.dart';
import '../model/recruitment_request_model.dart';

/// Technician: every recruitment application with its own status (active /
/// selected / not selected / cancelled) and the job post's status. Tapping
/// one opens the post's sheet on the job openings page.
class MyApplicationsPage extends GetView<MyApplicationsController> {
  const MyApplicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: CommonAppBar(
        title: TKeys.myApplications.tr,
        showLanguageToggle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.applications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.applications.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.fetchApplications,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.3),
                Icon(Icons.assignment_outlined, size: 64, color: colorScheme.outline),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    TKeys.noApplicationsFound.tr,
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
          onRefresh: controller.fetchApplications,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: controller.applications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final application = controller.applications[index];
              return _ApplicationCard(
                application: application,
                onTap: () async {
                  if (application.request.id.isEmpty) return;
                  await Get.toNamed(
                    AppRoutes.availableRecruitmentRequests,
                    arguments: {'id': application.request.id},
                  );
                  controller.fetchApplications();
                },
              );
            },
          ),
        );
      }),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final RecruitmentApplicationModel application;
  final VoidCallback onTap;

  const _ApplicationCard({required this.application, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final request = application.request;
    final bidInfo = BookingStatusHelper.bid(application.bid.status);
    final requestInfo = BookingStatusHelper.of(request.status);

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.borderColor),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      request.title.isEmpty ? TKeys.jobPost.tr : request.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _Chip(label: bidInfo.label, color: bidInfo.color),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                [
                  request.duration.isEmpty ? TKeys.durationNotSpecified.tr : request.duration,
                  if (request.category.isNotEmpty) request.category,
                ].join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: colorScheme.outlineVariant),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${TKeys.proposedSalaryLabel.tr}: ${application.bid.proposedSalaryLabel}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _Chip(label: requestInfo.label, color: requestInfo.color),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
