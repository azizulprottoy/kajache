import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controller/local_controller.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../../../shared/widgets/error_widget.dart';
import '../controllers/reword_controller.dart';
import '../models/reword_model.dart';

class RewardsPage extends GetView<RewardsController> {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localeController = Get.find<LocaleController>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CommonAppBar(
        title: TKeys.rewards.tr,
        showBack: true,
        showLanguageToggle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.rewards.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.rewards.isEmpty) {
          return AppErrorWidget(
            type: ErrorType.general,
            message: controller.errorMessage.value,
            onAction: controller.loadRewards,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadRewards,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              _PointsHeroCard(
                theme: theme,
                colorScheme: colorScheme,
                totalPoints: controller.totalPoints.value,
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  TKeys.availableRewards.tr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (controller.rewards.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: AppErrorWidget.empty(
                    title: TKeys.noRewardsAvailable.tr,
                  ),
                )
              else
                ...controller.rewards.map(
                  (reward) => _RewardCard(
                    reward: reward,
                    isUnlocked: controller.isUnlocked(reward),
                    pointsRemaining: controller.pointsRemaining(reward),
                    isBengali: localeController.isBengali,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _PointsHeroCard extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme colorScheme;
  final int totalPoints;

  const _PointsHeroCard({
    required this.theme,
    required this.colorScheme,
    required this.totalPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TKeys.totalRewardPoints.tr,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimary.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$totalPoints',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              TKeys.rewardPointsSubtitle.tr,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final RewordModel reward;
  final bool isUnlocked;
  final int pointsRemaining;
  final bool isBengali;

  const _RewardCard({
    required this.reward,
    required this.isUnlocked,
    required this.pointsRemaining,
    required this.isBengali,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Opacity(
      opacity: isUnlocked ? 1 : 0.6,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RewardImage(url: reward.imageUrl, colorScheme: colorScheme),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward.title(isBengali),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (reward.description(isBengali).isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      reward.description(isBengali),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  if (isUnlocked)
                    _StatusChip(
                      icon: Icons.check_circle_rounded,
                      label: TKeys.rewardUnlocked.tr,
                      color: colorScheme.primary,
                    )
                  else
                    _StatusChip(
                      icon: Icons.lock_outline_rounded,
                      label: '$pointsRemaining ${TKeys.rewardPointsToUnlock.tr}',
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${reward.minpoint}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _RewardImage extends StatelessWidget {
  final String url;
  final ColorScheme colorScheme;

  const _RewardImage({required this.url, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: url.isEmpty
          ? Icon(Icons.card_giftcard_rounded, color: colorScheme.primary)
          : Image.network(
              url,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              },
              errorBuilder: (_, __, ___) => Icon(
                Icons.card_giftcard_rounded,
                color: colorScheme.primary,
              ),
            ),
    );
  }
}
