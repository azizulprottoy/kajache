import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/controller/local_controller.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../../../shared/widgets/common_nav_bar.dart';
import '../../orders/bindings/order_binding.dart';
import '../../orders/views/orders_page.dart';
import '../../profile/models/worker_profile_model.dart';
import '../../rewords/bindings/reword_binding.dart';
import '../../rewords/views/reword_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localeController = Get.find<LocaleController>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CommonAppBar(
        title: 'Menu',
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
                  title: 'My Profile',
                  onTap: () {
                    Get.toNamed(
                      AppRoutes.myProfile,
                      arguments: ProfileType.serviceProvider,
                    );                  },
                ),
                _MenuDivider(),
                _MenuTile(
                  icon: Icons.history,
                  title: 'Previous Orders',
                  onTap: () {
                    Get.toNamed(
                      AppRoutes.previousOrders,
                    );

                  },
                ),
                _MenuDivider(),
                _MenuTile(
                  icon: Icons.card_giftcard_outlined,
                  title: 'Rewards',
                  onTap: () {
                    Get.toNamed(
                      AppRoutes.rewordPage,
                    );

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
                  title: 'Dark Mode',
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
                  title: 'Log Out',
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
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
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
            child: const Text('Log Out'),
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

      ),
      child: Column(children: children),
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
      color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.05),
    );
  }
}