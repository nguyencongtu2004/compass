import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:minecraft_compass/utils/format_utils.dart';
import '../../../models/newsfeed_post_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common_avatar.dart';

class PostCard extends StatelessWidget {
  final NewsfeedPost post;
  final VoidCallback? onDelete;

  const PostCard({super.key, required this.post, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                CommonAvatar(
                  radius: 20,
                  avatarUrl: post.userAvatarUrl,
                  displayName: post.userDisplayName,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userDisplayName,
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        FormatUtils.getShortTimeAgo(post.createdAt),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant(context),
                        ),
                      ),
                    ],
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.more_vert,
                      color: AppColors.onSurfaceVariant(context),
                    ),
                  ),
              ],
            ),
          ),

          // Caption (if exists)
          if (post.caption != null && post.caption!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(post.caption!, style: AppTextStyles.bodyMedium),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(AppSpacing.radiusLg),
              bottomRight: Radius.circular(AppSpacing.radiusLg),
            ),
            child: CachedNetworkImage(
              imageUrl: post.imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 300,
                color: AppColors.surfaceVariant(context),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary(context),
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 300,
                color: AppColors.surfaceVariant(context),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error,
                      color: AppColors.error(context),
                      size: 48,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Không thể tải ảnh',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.error(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ), // Location info (if exists)
          if (post.location != null) ...[
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.primary(context),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    post.location!.locationName ??
                        'Lat: ${post.location!.latitude.toStringAsFixed(4)}, Lng: ${post.location!.longitude.toStringAsFixed(4)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
