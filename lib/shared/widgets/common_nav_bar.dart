import 'package:flutter/material.dart';
import 'package:kaj_ache/app/theme/context_extension.dart';

class CommonBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final bool isServiceProvider;
  final ValueChanged<int> onTap;

  const CommonBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.isServiceProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          top: BorderSide(
            color: context.colors.outlineVariant.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            selectedIcon: isServiceProvider
                ? Icons.bar_chart_rounded
                : Icons.design_services,
            unselectedIcon: isServiceProvider
                ? Icons.bar_chart_outlined
                : Icons.design_services_outlined,
            isSelected: currentIndex == 0,
            onTap: () => onTap(0),
          ),

          _NavItem(
            selectedIcon: Icons.home,
            unselectedIcon: Icons.home_outlined,
            isSelected: currentIndex == 1,
            onTap: () => onTap(1),
          ),

          _NavItem(
            selectedIcon: Icons.person,
            unselectedIcon: Icons.person_outline,
            isSelected: currentIndex == 2,
            onTap: () => onTap(2),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData selectedIcon;
  final IconData unselectedIcon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.selectedIcon,
    required this.unselectedIcon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        isSelected ? selectedIcon : unselectedIcon,
        size: 30,
        color: isSelected
            ? context.colors.primary
            : context.colors.onSurfaceVariant,
      ),
    );
  }
}