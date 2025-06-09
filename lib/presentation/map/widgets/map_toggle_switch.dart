import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum MapDisplayMode { locations, friends, explore }

class MapToggleSwitch extends StatelessWidget {
  final MapDisplayMode currentMode;
  final VoidCallback onToggleToLocations;
  final VoidCallback onToggleToFriends;
  final VoidCallback onToggleToExplore;

  const MapToggleSwitch({
    super.key,
    required this.currentMode,
    required this.onToggleToLocations,
    required this.onToggleToFriends,
    required this.onToggleToExplore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: AppColors.surface(context),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface(context).withValues(alpha: 0.15),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MapToggleOption(
            icon: Icons.location_on,
            label: 'Vị trí',
            isSelected: currentMode == MapDisplayMode.locations,
            onTap: onToggleToLocations,
          ),
          _MapToggleOption(
            icon: Icons.group,
            label: 'Bạn bè',
            isSelected: currentMode == MapDisplayMode.friends,
            onTap: onToggleToFriends,
          ),
          _MapToggleOption(
            icon: Icons.explore,
            label: 'Khám phá',
            isSelected: currentMode == MapDisplayMode.explore,
            onTap: onToggleToExplore,
          ),
        ],
      ),
    );
  }
}

class _MapToggleOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MapToggleOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected ? AppColors.primary(context) : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.onPrimary(context)
                  : AppColors.onSurface(context).withValues(alpha: 0.7),
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AppColors.onPrimary(context)
                    : AppColors.onSurface(context).withValues(alpha: 0.7),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
