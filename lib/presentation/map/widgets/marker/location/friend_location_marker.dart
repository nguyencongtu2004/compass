import 'package:flutter/material.dart';
import 'package:minecraft_compass/models/user_model.dart';
import 'package:minecraft_compass/presentation/core/theme/app_colors.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';
import 'package:minecraft_compass/presentation/core/theme/app_text_styles.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_avatar.dart';

class FriendLocationMarker extends StatelessWidget {
  final UserModel friend;

  const FriendLocationMarker({super.key, required this.friend});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar bạn bè
        CommonAvatar(
          radius: 25,
          avatarUrl: friend.avatarUrl,
          displayName: friend.displayName,
          borderSpacing: 0,
          borderColor: AppColors.secondary(context),
        ),
        const SizedBox(height: AppSpacing.xs),

        // Tên bạn bè
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.outline(context).withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            friend.displayName,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurface(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
