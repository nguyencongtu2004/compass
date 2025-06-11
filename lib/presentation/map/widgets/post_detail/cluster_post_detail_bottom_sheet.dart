import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../models/newsfeed_post_model.dart';
import '../../../../utils/format_utils.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/common_avatar.dart';

/// Bottom sheet hiển thị chi tiết cluster với các post có thể chọn
class ClusterPostDetailBottomSheet extends StatefulWidget {
  final List<NewsfeedPost> posts;

  const ClusterPostDetailBottomSheet({super.key, required this.posts});

  @override
  State<ClusterPostDetailBottomSheet> createState() =>
      _ClusterPostDetailBottomSheetState();

  /// Static method để hiển thị bottom sheet
  static void show(BuildContext context, List<NewsfeedPost> posts) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      builder: (context) => ClusterPostDetailBottomSheet(posts: posts),
    );
  }
}

class _ClusterPostDetailBottomSheetState
    extends State<ClusterPostDetailBottomSheet> {
  int _selectedIndex = 0;

  NewsfeedPost get _selectedPost => widget.posts[_selectedIndex];

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header với thông tin người đăng và số lượng posts
                  _buildHeader(context),

                  // Main post detail
                  _buildMainPostDetail(context),

                  // Cluster images grid
                  if (widget.posts.length > 1) _buildClusterImagesGrid(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Avatar
          CommonAvatar(
            radius: 24,
            avatarUrl: _selectedPost.userAvatarUrl,
            displayName: _selectedPost.userDisplayName,
          ),
          const SizedBox(width: AppSpacing.sm),

          // User info và cluster info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedPost.userDisplayName,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.onSurface(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      FormatUtils.getTimeAgo(_selectedPost.createdAt),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant(context),
                      ),
                    ),
                    if (widget.posts.length > 1) ...[
                      Text(
                        ' • ',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant(context),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary(context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${widget.posts.length} bài viết',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.onPrimary(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
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
      ),
    );
  }

  Widget _buildMainPostDetail(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main image
          Container(
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
                imageUrl: _selectedPost.imageUrl,
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
          ),
          const SizedBox(height: AppSpacing.md),

          // Caption
          if (_selectedPost.caption != null &&
              _selectedPost.caption!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant(context).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _selectedPost.caption!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurface(context),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Location info
          if (_selectedPost.location != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer(
                  context,
                ).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary(context).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: AppColors.primary(context),
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _selectedPost.location!.locationName ??
                          'Lat: ${_selectedPost.location!.latitude.toStringAsFixed(4)}, Lng: ${_selectedPost.location!.longitude.toStringAsFixed(4)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurface(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }

  Widget _buildClusterImagesGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'Các bài viết khác trong khu vực',
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.onSurface(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Horizontal scrollable grid
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: widget.posts.length,
            itemBuilder: (context, index) {
              final post = widget.posts[index];
              final isSelected = index == _selectedIndex;

              return Padding(
                padding: EdgeInsets.only(
                  right: index == widget.posts.length - 1 ? 0 : AppSpacing.sm,
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary(context)
                            : AppColors.outline(context).withValues(alpha: 0.3),
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary(
                                  context,
                                ).withValues(alpha: 0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : [],
                    ),
                    child: Stack(
                      children: [
                        // Image
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: post.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppColors.surfaceVariant(context),
                                child: Icon(
                                  Icons.image,
                                  color: AppColors.onSurfaceVariant(context),
                                  size: 24,
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppColors.surfaceVariant(context),
                                child: Icon(
                                  Icons.broken_image,
                                  color: AppColors.onSurfaceVariant(context),
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Selected indicator
                        if (isSelected)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: AppColors.primary(context),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.onPrimary(context),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.check,
                                color: AppColors.onPrimary(context),
                                size: 12,
                              ),
                            ),
                          ),

                        // User avatar overlay (bottom-left)
                        Positioned(
                          bottom: 4,
                          left: 4,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            child: CommonAvatar(
                              radius: 10,
                              avatarUrl: post.userAvatarUrl,
                              displayName: post.userDisplayName,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}
