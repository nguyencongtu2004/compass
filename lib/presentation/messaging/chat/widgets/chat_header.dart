import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_back_button.dart';
import '../../../core/widgets/common_avatar.dart';
import '../../../../models/user_model.dart';

class ChatHeader extends StatelessWidget {
  final UserModel? otherUser;
  final bool isLoading;

  const ChatHeader({
    super.key,
    required this.otherUser,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kToolbarHeight,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonBackButton(),
              const SizedBox(width: AppSpacing.md),

              CommonAvatar(
                radius: 18,
                avatarUrl: otherUser?.avatarUrl ?? '',
                displayName: otherUser?.displayName ?? 'U',
                backgroundColor: AppColors.primary(context),
                textColor: AppColors.onPrimary(context),
              ),
              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: Text(
                  otherUser?.displayName ??
                      (isLoading ? 'Đang tải...' : 'Người dùng'),
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.onSurface(context),
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
