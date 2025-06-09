import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class MapBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const MapBackButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface(context).withValues(alpha: 0.15),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(Icons.arrow_back, color: AppColors.onSurface(context)),
          splashRadius: 24,
        ),
      ),
    );
  }
}
