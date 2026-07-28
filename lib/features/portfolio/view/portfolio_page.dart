import 'package:flutter/material.dart';
import '../../../app/theme/context_extension.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import '../../../app/theme/context_extension.dart';
import 'package:get/get.dart';

import '../../../core/utils/translation_keys.dart';
import '../../../shared/shimmers/portfolio_shimmer.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../controller/portfolio_controller.dart';
import '../model/portfolio_model.dart';

class PortfolioPage extends GetView<PortfolioController> {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CommonAppBar(
        title: TKeys.portfolio.tr,
        showBack: true,
        showLanguageToggle: true,
      ),
      floatingActionButton: Obx(
        () => FloatingActionButton.extended(
          onPressed: controller.isLoading.value
              ? null
              : () => _showPortfolioForm(context),
          icon: const Icon(Icons.add),
          label: Text(TKeys.addWork.tr),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const PortfolioShimmer();
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.portfolioItems.isEmpty) {
          return _ErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.loadPortfolio,
          );
        }

        if (controller.portfolioItems.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.loadPortfolio,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 150),
                _EmptyPortfolio(),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadPortfolio,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: controller.portfolioItems.length,
            itemBuilder: (context, index) {
              final item = controller.portfolioItems[index];
              return _PortfolioCard(
                item: item,
                isDeleting: controller.deletingId.value == item.id,
                onEdit: () => _showPortfolioForm(context, item: item),
                onDelete: () => _confirmDelete(context, item),
              );
            },
          ),
        );
      }),
    );
  }

  Future<void> _showPortfolioForm(
    BuildContext context, {
    PortfolioItem? item,
  }) async {
    if (item == null) {
      controller.prepareCreate();
    } else {
      controller.prepareEdit(item);
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final colorScheme = theme.colorScheme;

        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            14,
            20,
            MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: controller.formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item == null ? 'Add portfolio work' : 'Edit portfolio work',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        icon: const Icon(Icons.close),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => _PortfolioImagePicker(
                      selectedImage: controller.selectedImage.value,
                      existingImage: item?.imageUrl ?? '',
                      onTap: controller.isSaving.value
                          ? null
                          : controller.pickImage,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: controller.serviceDetailsController,
                    minLines: 3,
                    maxLines: 6,
                    textInputAction: TextInputAction.newline,
                    decoration: const InputDecoration(
                      labelText: 'Service details',
                      hintText: 'Describe the completed service',
                      prefixIcon: Icon(Icons.description_outlined),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Service details are required';
                      }
                      if (value.trim().length < 5) {
                        return 'Enter at least 5 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 22),
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: controller.isSaving.value
                            ? null
                            : () async {
                                final saved = item == null
                                    ? await controller.createPortfolio()
                                    : await controller.updatePortfolio(item);
                                if (saved && sheetContext.mounted) {
                                  Navigator.of(sheetContext).pop();
                                }
                              },
                        icon: controller.isSaving.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                item == null
                                    ? Icons.add_photo_alternate_outlined
                                    : Icons.save_outlined,
                              ),
                        label: Text(
                          controller.isSaving.value
                              ? 'Saving...'
                              : item == null
                                  ? 'Add work'
                                  : 'Save changes',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    PortfolioItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(TKeys.deletePortfolioConfirm.tr),
        content: const Text(
          'This portfolio item will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(TKeys.cancel.tr),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(TKeys.delete.tr),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.deletePortfolio(item);
    }
  }
}

class _PortfolioCard extends StatelessWidget {
  final PortfolioItem item;
  final bool isDeleting;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PortfolioCard({
    required this.item,
    required this.isDeleting,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _NetworkPortfolioImage(url: item.imageUrl),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.technitianName.isEmpty
                            ? 'Technician'
                            : item.technitianName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        item.servicedetails,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isDeleting)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  PopupMenuButton<String>(
                    tooltip: 'Portfolio actions',
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.edit_outlined),
                          title: Text(TKeys.edit.tr),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.delete_outline,
                            color: colorScheme.error,
                          ),
                          title: Text(
                            'Delete',
                            style: TextStyle(color: colorScheme.error),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioImagePicker extends StatelessWidget {
  final File? selectedImage;
  final String existingImage;
  final VoidCallback? onTap;

  const _PortfolioImagePicker({
    required this.selectedImage,
    required this.existingImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 190,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (selectedImage != null)
              Image.file(selectedImage!, fit: BoxFit.cover)
            else if (existingImage.isNotEmpty)
              _NetworkPortfolioImage(url: existingImage)
            else
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 10),
                  Text(TKeys.tapToSelectImage.tr),
                ],
              ),
            if (selectedImage != null || existingImage.isNotEmpty)
              Positioned(
                right: 12,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.edit_outlined, size: 18),
                      const SizedBox(width: 6),
                      Text(TKeys.change.tr),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NetworkPortfolioImage extends StatelessWidget {
  final String url;

  const _NetworkPortfolioImage({required this.url});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (url.isEmpty) return _imagePlaceholder(colorScheme);

    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
      errorBuilder: (_, __, ___) => _imagePlaceholder(colorScheme),
    );
  }

  Widget _imagePlaceholder(ColorScheme colorScheme) {
    return ColoredBox(
      color: colorScheme.surfaceContainerLowest,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 46,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _EmptyPortfolio extends StatelessWidget {
  const _EmptyPortfolio();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.work_outline,
            size: 72,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 18),
          Text(
            'No portfolio work yet',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap “Add Work” to show customers your completed services.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 56,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(TKeys.retry.tr),
            ),
          ],
        ),
      ),
    );
  }
}
