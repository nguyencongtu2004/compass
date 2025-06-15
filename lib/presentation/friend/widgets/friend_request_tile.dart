import 'package:minecraft_compass/config/l10n/localization_extensions.dart';
import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../core/widgets/common_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

class FriendRequestTile extends StatelessWidget {
  final UserModel requester;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const FriendRequestTile({
    super.key,
    required this.requester,
    required this.onAccept,
    required this.onDecline,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          gradient: LinearGradient(
            colors: [
              AppColors.primaryContainer(context).withValues(alpha: 0.3),
              AppColors.primaryContainer(context).withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          leading: CommonAvatar(
            radius: 28,
            avatarUrl: requester.avatarUrl,
            displayName: requester.displayName,
          ),
          title: Text(
            requester.displayName,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.onSurface(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            requester.username.isNotEmpty
                ? '@${requester.username}'
                : requester.email,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant(context),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.success(context),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.check, color: Colors.white),
                  onPressed: onAccept,
                  tooltip: context.l10n.accept,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.error(context),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: onDecline,
                  tooltip: context.l10n.reject,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
