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
    return SizedBox(
      height: 60,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
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

                 SizedBox(width: 20),

                _NavItem(
                  selectedIcon: Icons.person,
                  unselectedIcon: Icons.person_outline,
                  isSelected: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
              ],
            ),
          ),

          Positioned(
            top: -22,
            child: GestureDetector(
              onTap: () => onTap(1),
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentIndex == 1
                      ? context.colors.primary
                      : context.colors.surface,
                  border: Border.all(
                    color: context.colors.surface,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.16),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  currentIndex == 1 ? Icons.home : Icons.home_outlined,
                  size: 30,
                  color: currentIndex == 1
                      ? context.colors.onPrimary
                      : context.colors.primary,
                ),
              ),
            ),
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