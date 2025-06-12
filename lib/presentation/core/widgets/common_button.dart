import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final Widget? prefixIcon;
  final Color? borderColor;

  const CommonButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.prefixIcon,
    this.borderColor,
    // this.height = AppSpacing.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary(context),
          foregroundColor: textColor ?? AppColors.onPrimary(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            side: borderColor != null 
              ? BorderSide(color: borderColor!, width: 1.0)
              : BorderSide.none,
          ),
          elevation: AppSpacing.elevation2,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md3,
            vertical: AppSpacing.md,
          ),
        ),        child: isLoading
            ? SizedBox(
                height: AppSpacing.iconSm,
                width: AppSpacing.iconSm,
                child: CircularProgressIndicator(
                  color: textColor ?? AppColors.onPrimary(context),
                  strokeWidth: AppSpacing.border2,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (prefixIcon != null) ...[
                    prefixIcon!,
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    text,
                    style: AppTextStyles.buttonLarge.copyWith(
                      color: textColor ?? AppColors.onPrimary(context),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
