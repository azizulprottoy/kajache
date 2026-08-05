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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // ── Logo ──────────────────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 96,
                  height: 96,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    width: 96, height: 96,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(Icons.handyman_outlined,
                        size: 48, color: colorScheme.onPrimaryContainer),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── App name ──────────────────────────────────────────────────
              Text(
                'Kaj Ache',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                TKeys.aboutUsTagline.tr,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),

              // ── About card ────────────────────────────────────────────────
              _InfoCard(
                icon: Icons.info_outline_rounded,
                title: TKeys.aboutUsTitle.tr,
                body: TKeys.aboutUsBody.tr,
                colorScheme: colorScheme,
                theme: theme,
              ),
              const SizedBox(height: 14),

              // ── Mission card ──────────────────────────────────────────────
              _InfoCard(
                icon: Icons.emoji_objects_outlined,
                title: TKeys.ourMission.tr,
                body: TKeys.ourMissionBody.tr,
                colorScheme: colorScheme,
                theme: theme,
              ),
              const SizedBox(height: 14),

              // ── Contact card ──────────────────────────────────────────────
              _InfoCard(
                icon: Icons.contact_support_outlined,
                title: TKeys.contactTitle.tr,
                body: TKeys.contactBody.tr,
                colorScheme: colorScheme,
                theme: theme,
              ),
              const SizedBox(height: 28),

              // ── Social media row ──────────────────────────────────────────
              Text(
                TKeys.followUs.tr,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              Obx(() {
                if (controller.isLoading.value) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (_) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLowest,
                        shape: BoxShape.circle,
                      ),
                    )),
                  );
                }

                if (controller.socialMedias.isEmpty) {
                  return Text(
                    TKeys.noSocialMediaAvailable.tr,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant),
                  );
                }

                return Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: controller.socialMedias.map((item) =>
                    _SocialIcon(
                      item: item,
                      onTap: () => controller.openLink(item.url),
                      colorScheme: colorScheme,
                    ),
                  ).toList(),
                );
              }),

              const SizedBox(height: 32),

              // ── Version ───────────────────────────────────────────────────
              Text(
                TKeys.appVersion.tr,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Info card ─────────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: colorScheme.onPrimaryContainer),
            ),
            const SizedBox(width: 10),
            Text(title,
                style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface)),
          ]),
          const SizedBox(height: 10),
          Text(body,
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant, height: 1.6)),
        ],
      ),
    );
  }
}

// ── Social icon button ────────────────────────────────────────────────────────
class _SocialIcon extends StatelessWidget {
  final SocialMediaModel item;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _SocialIcon({
    required this.item,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: item.name,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: item.image.isNotEmpty
                    ? Image.network(
                        item.image,
                        width: 56, height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                            Icons.public_rounded,
                            color: colorScheme.primary),
                      )
                    : Icon(Icons.public_rounded, color: colorScheme.primary),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
