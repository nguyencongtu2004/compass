import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../models/newsfeed_post_model.dart';
import '../../../../utils/format_utils.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/common_avatar.dart';

/// Bottom sheet hiển thị chi tiết post khi click vào single post marker
class SinglePostDetailBottomSheet extends StatelessWidget {
  final NewsfeedPost post;

  const SinglePostDetailBottomSheet({super.key, required this.post});

    /// Static method để hiển thị bottom sheet
  static void show(BuildContext context, NewsfeedPost post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SinglePostDetailBottomSheet(post: post),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outline(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header với thông tin người đăng
                  _buildHeader(context),
                  const SizedBox(height: AppSpacing.md),

                  // Image
                  _buildImage(context),
                  const SizedBox(height: AppSpacing.md),

                  // Caption
                  if (post.caption != null && post.caption!.isNotEmpty) ...[
                    _buildCaption(context),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // Location info
                  if (post.location != null) _buildLocationInfo(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Avatar
        CommonAvatar(
          radius: 24,
          avatarUrl: post.userAvatarUrl,
          displayName: post.userDisplayName,
        ),
        const SizedBox(width: AppSpacing.sm),

        // User info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.userDisplayName,
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.onSurface(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                FormatUtils.getTimeAgo(post.createdAt),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant(context),
                ),
              ),
            ],
          ),
        ),

        // Close button
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.close, color: AppColors.onSurfaceVariant(context)),
        ),
      ],
    );
  }

  Widget _buildImage(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface(context).withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: post.imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 200,
            color: AppColors.surfaceVariant(context),
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            height: 200,
            color: AppColors.surfaceVariant(context),
            child: Icon(
              Icons.broken_image,
              color: AppColors.onSurfaceVariant(context),
              size: 48,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCaption(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant(context).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        post.caption!,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.onSurface(context),
        ),
      ),
    );
  }

  Widget _buildLocationInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer(context).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary(context).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: AppColors.primary(context), size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              post.location!.locationName ??
                  'Lat: ${post.location!.latitude.toStringAsFixed(4)}, Lng: ${post.location!.longitude.toStringAsFixed(4)}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurface(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
