import 'package:flutter/material.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';

class CommonBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isArrowRight;
  const CommonBackButton({
    super.key,
    this.onPressed,
    this.isArrowRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onPressed != null) {
          onPressed!();
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Icon(
        isArrowRight ? Icons.arrow_forward : Icons.arrow_back,
        size: AppSpacing.md4,
      ),
    );
  }
}
