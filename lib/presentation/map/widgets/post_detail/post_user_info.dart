import 'package:flutter/material.dart';
import 'package:minecraft_compass/models/newsfeed_post_model.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';
import 'package:minecraft_compass/presentation/core/theme/app_text_styles.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_avatar.dart';
import 'package:minecraft_compass/utils/format_utils.dart';

class PostUserInfo extends StatelessWidget {
  const PostUserInfo({super.key, required this.post});

  final NewsfeedPost post;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar
        CommonAvatar(
          radius: 18,
          avatarUrl: post.userAvatarUrl,
          displayName: post.userDisplayName,
        ),
        const SizedBox(width: AppSpacing.sm),

        // User info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                post.userDisplayName,
                style: AppTextStyles.titleSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      offset: const Offset(1, 1),
                      blurRadius: 3,
                      color: Colors.black.withValues(alpha: 0.8),
                    ),
                  ],
                ),
              ),
              Text(
                FormatUtils.getTimeAgo(post.createdAt),
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  shadows: [
                    Shadow(
                      offset: const Offset(1, 1),
                      blurRadius: 3,
                      color: Colors.black.withValues(alpha: 0.8),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
