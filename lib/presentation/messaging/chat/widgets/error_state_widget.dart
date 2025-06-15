import 'package:minecraft_compass/config/l10n/localization_extensions.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorStateWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: AppSpacing.iconXxl * 2,
            color: AppColors.error(context),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.anErrorHasOccurred,
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.error(context),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md3),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(context.l10n.tryAgain),
          ),
        ],
      ),
    );
  }
}
