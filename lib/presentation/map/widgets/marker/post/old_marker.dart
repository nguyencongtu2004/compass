import 'package:flutter/material.dart';
import 'package:minecraft_compass/models/newsfeed_post_model.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:minecraft_compass/presentation/core/theme/app_text_styles.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_avatar.dart';
import 'package:minecraft_compass/utils/format_utils.dart';
import '../../../../core/theme/app_spacing.dart';

// TODO mai check lại nha
class FeedMarker extends StatelessWidget {
  final NewsfeedPost post;

  const FeedMarker({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Hình ảnh feed post
        CommonCachedNetworkImage(
          imageUrl: post.imageUrl.isNotEmpty ? post.imageUrl : '',
          border: Border.all(color: AppColors.primary(context), width: 2),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface(context).withValues(alpha: 0.2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
        const SizedBox(height: AppSpacing.xs),

        // Thông tin người đăng
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.outline(context).withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.onSurface(context).withValues(alpha: 0.1),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar người đăng
              CommonAvatar(
                radius: 12,
                avatarUrl: post.userAvatarUrl,
                displayName: post.userDisplayName,
              ),
              const SizedBox(width: AppSpacing.xs),

              // Caption người đăng
              post.caption == null || post.caption!.isEmpty
                  ? const SizedBox.shrink()
                  : Text(
                      post.caption!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurface(context),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

              // // Tên người đăng
              // Text(
              //   post.userDisplayName,
              //   style: AppTextStyles.bodySmall.copyWith(
              //     color: AppColors.onSurface(context),
              //     fontWeight: FontWeight.w500,
              //   ),
              //   maxLines: 1,
              //   overflow: TextOverflow.ellipsis,
              // ),

              // // Khoảng cách giữa tên và thời gian
              Text(
                ' • ',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurface(context).withValues(alpha: 0.6),
                ),
              ),

              // Thời gian đăng
              Text(
                FormatUtils.getShortTimeAgo(post.createdAt),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurface(context).withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
