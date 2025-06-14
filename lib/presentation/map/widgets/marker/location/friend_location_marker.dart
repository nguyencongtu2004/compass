import 'package:flutter/material.dart';
import 'package:minecraft_compass/models/user_model.dart';
import 'package:minecraft_compass/presentation/core/theme/app_colors.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';
import 'package:minecraft_compass/presentation/core/theme/app_text_styles.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_avatar.dart';
import 'package:minecraft_compass/presentation/map/widgets/marker/location/friend_action_popup.dart';

class FriendLocationMarker extends StatelessWidget {
  final UserModel friend;

  const FriendLocationMarker({super.key, required this.friend});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Hiển thị popup với các tùy chọn
        FriendActionPopup.show(context, friend);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar bạn bè
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary(context).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CommonAvatar(
              radius: 25,
              avatarUrl: friend.avatarUrl,
              displayName: friend.displayName,
              borderSpacing: 2,
              borderColor: AppColors.secondary(context),
            ),
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
              boxShadow: [
                BoxShadow(
                  color: AppColors.onSurface(context).withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              friend.displayName,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurface(context),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
