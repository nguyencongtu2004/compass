import 'package:minecraft_compass/config/l10n/localization_extensions.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_avatar.dart';
import '../../../../models/user_model.dart';

class EmptyMessagesWidget extends StatelessWidget {
  final UserModel? otherUser;
  final bool isLoading;

  const EmptyMessagesWidget({
    super.key,
    required this.otherUser,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CommonAvatar(
            radius: 40,
            avatarUrl: otherUser?.avatarUrl ?? '',
            displayName: otherUser?.displayName ?? 'U',
            backgroundColor: AppColors.primary(context),
            textColor: AppColors.onPrimary(context),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.chatWithDisplayname(
              otherUser?.displayName ??
                  (isLoading ? context.l10n.loading : context.l10n.friends),
            ),
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.onSurface(context),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isLoading
                ? context.l10n.loadingConversation
                : context.l10n.sendTheFirstMessageToStartAConversation,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
