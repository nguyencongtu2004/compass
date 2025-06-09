import 'package:flutter/material.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';
import '../../core/theme/app_colors.dart';

class MapFloatingActionButtons extends StatelessWidget {
  final VoidCallback onResetRotationPressed;
  final VoidCallback onMyLocationPressed;

  const MapFloatingActionButtons({
    super.key,
    required this.onResetRotationPressed,
    required this.onMyLocationPressed,
  });
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Button reset rotation về hướng Bắc
          // FloatingActionButton(
          //   mini: true,
          //   heroTag: "reset_rotation",
          //   backgroundColor: AppColors.secondary(context),
          //   foregroundColor: AppColors.onSecondary(context),
          //   elevation: 6,
          //   onPressed: onResetRotationPressed,
          //   child: const Icon(Icons.explore, size: AppSpacing.iconMd),
          // ),
          // const SizedBox(height: 12),

          // Button về vị trí hiện tại
          FloatingActionButton(
            mini: true,
            heroTag: "my_location",
            backgroundColor: AppColors.primary(context),
            foregroundColor: AppColors.onPrimary(context),
            elevation: 6,
            onPressed: onMyLocationPressed,
            child: const Icon(Icons.my_location, size: AppSpacing.iconMd),
          ),
        ],
      ),
    );
  }
}
