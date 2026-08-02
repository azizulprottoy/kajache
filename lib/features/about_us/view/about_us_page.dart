import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/context_extension.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../controller/about_us_controller.dart';
import '../model/social_media_model.dart';

class AboutUsPage extends GetView<AboutUsController> {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CommonAppBar(
        title: TKeys.aboutUs.tr,
        showBack: true,
        showLanguageToggle: true,
      ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const _SocialMediaShimmer();
          }

          if (controller.socialMedias.isEmpty) {
            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              children: [
                Center(
                  child: Text(
                    TKeys.noSocialMediaAvailable.tr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.socialMedias.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = controller.socialMedias[index];
              return _SocialMediaTile(
                item: item,
                onTap: () => controller.openLink(item.url),
              );
            },
          );
        }),
      ),
    );
  }
}

class _SocialMediaTile extends StatelessWidget {
  final SocialMediaModel item;
  final VoidCallback onTap;

  const _SocialMediaTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.borderColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: item.image.isNotEmpty
              ? Image.network(
                  item.image,
                  width: 42,
                  height: 42,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallbackIcon(colorScheme),
                )
              : _fallbackIcon(colorScheme),
        ),
        title: Text(
          item.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        trailing: Icon(
          Icons.open_in_new_rounded,
          size: 18,
          color: colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _fallbackIcon(ColorScheme colorScheme) {
    return Container(
      width: 42,
      height: 42,
      color: colorScheme.primary.withOpacity(0.10),
      child: Icon(Icons.public_rounded, color: colorScheme.primary),
    );
  }
}

class _SocialMediaShimmer extends StatelessWidget {
  const _SocialMediaShimmer();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => Container(
        height: 58,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorScheme.borderColor),
        ),
      ),
    );
  }
}
