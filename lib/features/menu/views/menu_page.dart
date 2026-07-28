import 'package:flutter/material.dart';
import '../../../app/theme/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/controller/local_controller.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../../main/controller/main_controller.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localeController = Get.find<LocaleController>();

    final mainController = Get.find<MainController>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CommonAppBar(
        title: TKeys.menuTitle.tr,
        showLanguageToggle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _MenuSectionCard(
              children: [
                _MenuTile(
                  icon: Icons.person_outline,
                  title: TKeys.myProfile.tr,
                  onTap: () {
                    Get.toNamed(AppRoutes.myProfile);
                  },
                ),
                _MenuDivider(),
                _MenuTile(
                  icon: Icons.work_outline,
                  title: TKeys.myBookings.tr,
                  onTap: () {
                    Get.toNamed(AppRoutes.myBookings);
                  },
                ),
                if (mainController.isServiceProvider) ...[
                  _MenuTile(
                    icon: Icons.work_history_outlined,
                    title: TKeys.portfolio.tr,
                    onTap: () {
                      Get.toNamed(AppRoutes.portfolioPage);
                    },
                  ),
                ],
                _MenuDivider(),
                _MenuTile(
                  icon: Icons.fire_extinguisher_sharp,
                  title: TKeys.rewards.tr,
                  onTap: () {
                    Get.toNamed(AppRoutes.rewordPage);
                  },
                ),
                _MenuDivider(),
                _MenuTile(
                  icon: Icons.chat_bubble_outline,
                  title: TKeys.chat.tr,
                  onTap: () {
                    Get.toNamed(AppRoutes.chatPage);
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            _MenuSectionCard(
              children: [
                _MenuTile(
                  icon: Icons.support_agent_outlined,
                  title: TKeys.customerSupport.tr,
                  onTap: () {
                    Get.toNamed(AppRoutes.customerSupportPage);
                  },
                ),
                _MenuDivider(),
                _MenuTile(
                  icon: Icons.privacy_tip_outlined,
                  title: TKeys.privacyPolicy.tr,
                  onTap: () {
                    Get.toNamed(AppRoutes.privacyPolicyPage);
                  },
                ),
                _MenuDivider(),
                _MenuTile(
                  icon: Icons.description_outlined,
                  title: TKeys.termsConditions.tr,
                  onTap: () {
                    Get.toNamed(AppRoutes.termsConditionPage);
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            _MenuSectionCard(
              children: [
                _SwitchMenuTile(
                  icon: Get.isDarkMode
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                  title: TKeys.darkMode.tr,
                  value: Get.isDarkMode,
                  onChanged: (value) {
                    Get.changeThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                ),
                _MenuDivider(),
                Obx(
                      () => _SwitchMenuTile(
                    icon: Icons.language_outlined,
                    title: 'বাংলা / English',
                    value: localeController.isBengali,
                    onChanged: (value) {
                      if (value) {
                        localeController.setBengali();
                      } else {
                        localeController.setEnglish();
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _MenuSectionCard(
              children: [
                _MenuTile(
                  icon: Icons.logout_rounded,
                  title: TKeys.logout.tr,
                  textColor: colorScheme.error,
                  iconColor: colorScheme.error,
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(TKeys.logout.tr),
        content: Text(TKeys.logoutConfirm.tr),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(TKeys.cancel.tr),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Get.back();
              Get.offAllNamed(AppRoutes.login);
            },
            child: Text(TKeys.logout.tr),
          ),
        ],
      ),
    );
  }
}

class _MenuSectionCard extends StatelessWidget {
  final List<Widget> children;

  const _MenuSectionCard({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.borderColor,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: (iconColor ?? colorScheme.primary).withOpacity(0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: iconColor ?? colorScheme.primary,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: textColor ?? colorScheme.onSurface,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 18,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}

class _SwitchMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchMenuTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: colorScheme.primary,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: colorScheme.onPrimary,
        activeTrackColor: colorScheme.primary,
        inactiveThumbColor: colorScheme.outline,
        inactiveTrackColor: colorScheme.surfaceContainerHighest,
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: Theme.of(context).colorScheme.borderColor,
    );
  }
}