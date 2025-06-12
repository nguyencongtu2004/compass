import 'package:flutter/material.dart';
import 'package:minecraft_compass/models/newsfeed_post_model.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';
import 'package:minecraft_compass/presentation/core/theme/app_text_styles.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_cached_network_image.dart';

class PostImageWithCaption extends StatelessWidget {
  const PostImageWithCaption({super.key, required this.post, this.index});

  final NewsfeedPost post;
  final int? index;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Hero(
            tag: '${post.id}_${index ?? 0}',
            child: AspectRatio(
              aspectRatio: 1, // Định dạng vuông
              child: CommonCachedNetworkImage(
                imageUrl: post.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),

          // Caption đè lên ảnh ở giữa phía dưới
          if (post.caption != null && post.caption!.isNotEmpty)
            Positioned(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(AppSpacing.lg),
                  ),
                  child: Text(
                    post.caption!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
