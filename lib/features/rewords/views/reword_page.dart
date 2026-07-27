import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controller/local_controller.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../shared/shimmers/rewards_shimmer.dart';
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showHowToEarnSheet(context),
        tooltip: TKeys.howToEarnPoints.tr,
        child: const Icon(Icons.note_alt_outlined),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.rewards.isEmpty) {
          return const RewardsShimmer();
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              _PointsHeroCard(
                theme: theme,
                colorScheme: colorScheme,
                totalPoints: controller.totalPoints.value,
                rewards: controller.rewards,
              ),
              const SizedBox(height: 24),
              Text(
                TKeys.rewardMilestones.tr,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              if (controller.rewards.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: AppErrorWidget.empty(
                    title: TKeys.noRewardsAvailable.tr,
                  ),
                )
              else
                ...List.generate(controller.rewards.length, (i) {
                  final reward = controller.rewards[i];
                  return _ChecklistItem(
                    reward: reward,
                    isUnlocked: controller.isUnlocked(reward),
                    pointsRemaining: controller.pointsRemaining(reward),
                    isBengali: localeController.isBengali,
                    isFirst: i == 0,
                    isLast: i == controller.rewards.length - 1,
                  );
                }),
            ],
          ),
        );
      }),
    );
  }

  void _showHowToEarnSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _HowToEarnSheet(),
    );
  }
}

// ── Points hero card ──────────────────────────────────────────────────────────
class _PointsHeroCard extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme colorScheme;
  final int totalPoints;
  final List<RewordModel> rewards;

  const _PointsHeroCard({
    required this.theme,
    required this.colorScheme,
    required this.totalPoints,
    required this.rewards,
  });

  @override
  Widget build(BuildContext context) {
    // Find next locked milestone
    RewordModel? next;
    for (final r in rewards) {
      if (totalPoints < r.minpoint) {
        next = r;
        break;
      }
    }

    final progressValue = next == null
        ? 1.0
        : totalPoints / max(next.minpoint, 1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.75),
          ],
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
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$totalPoints',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progressValue.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: colorScheme.onPrimary.withValues(alpha: 0.25),
              valueColor:
                  AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
            ),
          ),
          const SizedBox(height: 8),
          if (next != null)
            Text(
              '${TKeys.nextMilestone.tr}: ${next.minpoint} ${TKeys.pts.tr}  •  ${next.minpoint - totalPoints} ${TKeys.pts.tr} ${TKeys.rewardPointsToUnlock.tr}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimary.withValues(alpha: 0.9),
              ),
            )
          else
            Text(
              TKeys.rewardPointsSubtitle.tr,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimary.withValues(alpha: 0.9),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Timeline checklist item ───────────────────────────────────────────────────
class _ChecklistItem extends StatelessWidget {
  final RewordModel reward;
  final bool isUnlocked;
  final int pointsRemaining;
  final bool isBengali;
  final bool isFirst;
  final bool isLast;

  const _ChecklistItem({
    required this.reward,
    required this.isUnlocked,
    required this.pointsRemaining,
    required this.isBengali,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final lineColor = isUnlocked
        ? colorScheme.primary
        : colorScheme.outlineVariant;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Timeline column ──────────────────────────────────────────────
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Line above the dot (hidden for first item)
                if (!isFirst)
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: 2,
                      color: lineColor.withValues(alpha: 0.4),
                    ),
                  )
                else
                  const SizedBox(height: 8),

                // Dot
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isUnlocked
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                    border: Border.all(
                      color: isUnlocked
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isUnlocked
                        ? Icons.check_rounded
                        : Icons.lock_outline_rounded,
                    size: 14,
                    color: isUnlocked
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),

                // Line below the dot (hidden for last item)
                if (!isLast)
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: 2,
                      color: lineColor.withValues(alpha: 0.4),
                    ),
                  )
                else
                  const SizedBox(height: 8),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ── Card ─────────────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Opacity(
                opacity: isUnlocked ? 1.0 : 0.65,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? colorScheme.primaryContainer.withValues(alpha: 0.35)
                        : colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isUnlocked
                          ? colorScheme.primary.withValues(alpha: 0.3)
                          : colorScheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      _RewardImage(
                          url: reward.imageUrl, colorScheme: colorScheme),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reward.title(isBengali),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            if (reward.description(isBengali).isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                reward.description(isBengali),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            if (isUnlocked)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_rounded,
                                      size: 15,
                                      color: colorScheme.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    TKeys.rewardUnlocked.tr,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.lock_outline_rounded,
                                      size: 15,
                                      color: colorScheme.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$pointsRemaining ${TKeys.pts.tr} ${TKeys.rewardPointsToUnlock.tr}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isUnlocked
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${reward.minpoint}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isUnlocked
                                ? colorScheme.onPrimary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reward image ──────────────────────────────────────────────────────────────
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
        color: colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: url.isEmpty
          ? Icon(Icons.card_giftcard_rounded, color: colorScheme.primary)
          : Image.network(
              url,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) =>
                  progress == null ? child : const SizedBox(),
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.card_giftcard_rounded, color: colorScheme.primary),
            ),
    );
  }
}

// ── How-to-earn bottom sheet ──────────────────────────────────────────────────
class _HowToEarnSheet extends StatelessWidget {
  const _HowToEarnSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final actions = [
      _EarnAction(
        icon: Icons.person_outline_rounded,
        labelKey: TKeys.earnByProfile,
        points: 20,
      ),
      _EarnAction(
        icon: Icons.handyman_outlined,
        labelKey: TKeys.earnByBooking,
        points: 10,
      ),
      _EarnAction(
        icon: Icons.rate_review_outlined,
        labelKey: TKeys.earnByReview,
        points: 10,
      ),
      _EarnAction(
        icon: Icons.star_outline_rounded,
        labelKey: TKeys.earnByRating,
        points: 10,
      ),
      _EarnAction(
        icon: Icons.chat_bubble_outline_rounded,
        labelKey: TKeys.earnByComment,
        points: 5,
      ),
      _EarnAction(
        icon: Icons.reply_rounded,
        labelKey: TKeys.earnByReply,
        points: 5,
      ),
    ];

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  TKeys.howToEarnPoints.tr,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                ...actions.map((a) => _EarnActionTile(action: a)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EarnAction {
  final IconData icon;
  final String labelKey;
  final int points;

  const _EarnAction({
    required this.icon,
    required this.labelKey,
    required this.points,
  });
}

class _EarnActionTile extends StatelessWidget {
  final _EarnAction action;

  const _EarnActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(action.icon, color: colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              action.labelKey.tr,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '+${action.points} ${TKeys.pts.tr}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
