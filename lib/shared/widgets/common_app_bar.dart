import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controller/local_controller.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showLanguageToggle;
  final bool showBack;

  const CommonAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.actions,
    this.showLanguageToggle = true,
    this.showBack = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme            = Theme.of(context);
    final colorScheme      = theme.colorScheme;
    final localeController = Get.find<LocaleController>();

    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: showBack
          ? BackButton(color: colorScheme.onSurface)
          : null,

      title: title != null
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title!.tr,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),

        ],
      )
          : null,

      actions: [
        // ── Language toggle ──────────────────────────────────────────────
        if (showLanguageToggle)
          Obx(() {
            final isBengali = localeController.isBengali;
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LangOption(
                    label: 'EN',
                    isSelected: !isBengali,
                    onTap: localeController.setEnglish,
                    colorScheme: colorScheme,
                    theme: theme,
                    isLeft: true,
                  ),
                  _LangOption(
                    label: 'বাং',
                    isSelected: isBengali,
                    onTap: localeController.setBengali,
                    colorScheme: colorScheme,
                    theme: theme,
                    isLeft: false,
                  ),
                ],
              ),
            );
          }),


          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_outlined,
                color: Theme.of(context).colorScheme.onSurface),
          ),


        const SizedBox(width: 4),
      ],
    );
  }
}

class _LangOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final bool isLeft;

  const _LangOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
    required this.theme,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.horizontal(
            left:  isLeft  ? const Radius.circular(20) : Radius.zero,
            right: !isLeft ? const Radius.circular(20) : Radius.zero,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}