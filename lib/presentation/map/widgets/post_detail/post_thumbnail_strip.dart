import 'package:flutter/material.dart';
import 'package:minecraft_compass/models/newsfeed_post_model.dart';
import 'package:minecraft_compass/presentation/core/theme/app_colors.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_cached_network_image.dart';

class PostThumbnailStrip extends StatelessWidget {
  const PostThumbnailStrip({
    super.key,
    required this.posts,
    required this.onThumbnailTap,
    required this.currentIndex,
  });

  final List<NewsfeedPost> posts;
  final int currentIndex;
  final void Function(int) onThumbnailTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          final isSelected = index == currentIndex;
          return GestureDetector(
            onTap: () => onThumbnailTap(index),
            child: Container(
              width: 80,
              height: 80, // Đảm bảo container cũng có chiều cao cố định
              margin: const EdgeInsets.only(right: AppSpacing.sm),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(color: AppColors.primary(context), width: 2)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CommonCachedNetworkImage(
                  imageUrl: post.imageUrl,
                  fit: BoxFit.cover,
                  width: 80,
                  height: 80,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
