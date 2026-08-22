import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/context_extension.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../controller/available_recruitment_requests_controller.dart';
import '../model/recruitment_request_model.dart';

class AvailableRecruitmentRequestsPage
    extends GetView<AvailableRecruitmentRequestsController> {
  const AvailableRecruitmentRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: CommonAppBar(
        title: TKeys.availableRecruitmentRequests.tr,
        showBack: false,
        showLanguageToggle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.availableRequests.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.fetchAvailableRequests,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.3),
                Icon(Icons.badge_outlined, size: 64, color: colorScheme.outline),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    TKeys.noOpenJobsFound.tr,
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
          onRefresh: controller.fetchAvailableRequests,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: controller.availableRequests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final item = controller.availableRequests[index];
              return _JobOpeningCard(
                item: item,
                onTap: () async {
                  await controller.openRequest(item.id);
                  if (controller.selectedRequest.value == null) return;
                  Get.bottomSheet(
                    _ApplySheet(controller: controller),
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                  ).whenComplete(controller.clearSelectedRequest);
                },
              );
            },
          ),
        );
      }),
    );
  }
}

class _JobOpeningCard extends StatelessWidget {
  final RecruitmentRequestModel item;
  final VoidCallback onTap;

  const _JobOpeningCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      elevation: 1,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.08),
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
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.badge_outlined, color: colorScheme.onPrimaryContainer),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title.isEmpty ? 'Job Opening' : item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.duration.isEmpty ? 'Duration not specified' : item.duration,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    item.salaryLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),

              if (item.details.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  item.details.replaceAll(RegExp(r'<[^>]*>'), '').trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.4),
                ),
              ],

              const SizedBox(height: 12),
              Divider(height: 1, color: colorScheme.outlineVariant),
              const SizedBox(height: 10),

              Row(
                children: [
                  if (item.locationText.isNotEmpty) ...[
                    Icon(Icons.location_on_outlined, size: 16, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.locationText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ] else
                    const Spacer(),
                  Icon(Icons.people_alt_outlined, size: 16, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    '${item.bidsCount}',
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApplySheet extends StatefulWidget {
  final AvailableRecruitmentRequestsController controller;

  const _ApplySheet({required this.controller});

  @override
  State<_ApplySheet> createState() => _ApplySheetState();
}

class _ApplySheetState extends State<_ApplySheet> {
  final _formKey = GlobalKey<FormState>();
  final _salaryController = TextEditingController();
  final _messageController = TextEditingController();
  bool _prefilled = false;

  @override
  void dispose() {
    _salaryController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _prefillIfNeeded(RecruitmentRequestDetailsModel? detail) {
    if (_prefilled || detail == null) return;
    final myBid = detail.myBid;
    if (myBid != null) {
      _salaryController.text = myBid.proposedSalary.toInt().toString();
      _messageController.text = myBid.message;
    }
    _prefilled = true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await widget.controller.submitBid(
      proposedSalary: num.tryParse(_salaryController.text.trim()) ?? 0,
      message: _messageController.text,
    );

    if (!success || !mounted) return;

    final wasUpdate = widget.controller.selectedRequest.value?.hasBid ?? false;
    Navigator.of(context).pop();
    Get.snackbar(
      wasUpdate ? TKeys.applicationUpdated.tr : TKeys.applicationSubmitted.tr,
      wasUpdate ? '' : TKeys.applicationSubmittedMsg.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Obx(() {
      final controller = widget.controller;
      final detail = controller.selectedRequest.value;

      if (controller.isLoadingDetails.value && detail == null) {
        return const SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      }

      if (detail == null) return const SizedBox.shrink();

      _prefillIfNeeded(detail);
      final isUpdate = detail.hasBid;

      return SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colors.outlineVariant,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      detail.title.isEmpty ? 'Job Opening' : detail.title,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detail.duration.isEmpty ? 'Duration not specified' : detail.duration,
                      style:
                          theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                    ),
                    if (detail.details.trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        detail.details,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: colors.onSurfaceVariant, height: 1.4),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(children: [
                        Expanded(
                          child: Text(TKeys.jobBudget.tr,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: colors.onSurfaceVariant)),
                        ),
                        Text(detail.salaryLabel,
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold, color: colors.primary)),
                      ]),
                    ),

                    const SizedBox(height: 18),
                    const Divider(height: 1),
                    const SizedBox(height: 16),

                    Text(
                      isUpdate ? TKeys.updateApplication.tr : TKeys.applyNow.tr,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _salaryController,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final n = num.tryParse(v?.trim() ?? '');
                        if (n == null || n <= 0) return 'Please enter a valid salary';
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: TKeys.proposedSalaryLabel.tr,
                        hintText: TKeys.proposedSalaryHint.tr,
                        prefixText: '৳ ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _messageController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: TKeys.applicationMessageLabel.tr,
                        hintText: TKeys.applicationMessageHint.tr,
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),

                    const SizedBox(height: 18),
                    Obx(() {
                      final submitting = controller.isSubmittingBid.value;
                      return SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: submitting ? null : _submit,
                          child: submitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(isUpdate ? TKeys.updateApplication.tr : TKeys.applyNow.tr),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
