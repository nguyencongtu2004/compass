import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class MapFloatingActionButtons extends StatelessWidget {
  final bool showFitBoundsButton;
  final VoidCallback onFitBoundsPressed;
  final VoidCallback onMyLocationPressed;

  const MapFloatingActionButtons({
    super.key,
    required this.showFitBoundsButton,
    required this.onFitBoundsPressed,
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
          // Button zoom to fit all markers
          if (showFitBoundsButton) ...[
            FloatingActionButton(
              mini: true,
              heroTag: "fit_bounds",
              backgroundColor: AppColors.secondary(context),
              foregroundColor: AppColors.onSecondary(context),
              elevation: 6,
              onPressed: onFitBoundsPressed,
              child: const Icon(Icons.fit_screen, size: 20),
            ),
            const SizedBox(height: 12),
          ],

          // Button về vị trí hiện tại
          FloatingActionButton(
            mini: true,
            heroTag: "my_location",
            backgroundColor: AppColors.primary(context),
            foregroundColor: AppColors.onPrimary(context),
            elevation: 6,
            onPressed: onMyLocationPressed,
            child: const Icon(Icons.my_location, size: 20),
          ),
        ],
      ),
    );
  }
}
