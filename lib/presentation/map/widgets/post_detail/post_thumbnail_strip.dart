import 'package:flutter/material.dart';
import 'package:minecraft_compass/models/newsfeed_post_model.dart';
import 'package:minecraft_compass/presentation/core/theme/app_colors.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_cached_network_image.dart';

class PostThumbnailStrip extends StatefulWidget {
  const PostThumbnailStrip({
    super.key,
    required this.posts,
    required this.currentIndex,
    required this.onThumbnailTap,
  });

  final List<NewsfeedPost> posts;
  final int currentIndex;
  final void Function(int) onThumbnailTap;

  @override
  State<PostThumbnailStrip> createState() => _PostThumbnailStripState();
}

class _PostThumbnailStripState extends State<PostThumbnailStrip> {
  int _currentIndex = 0;

  @override
  void initState() {
    _currentIndex = widget.currentIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: widget.posts.length,
        itemBuilder: (context, index) {
          final post = widget.posts[index];
          final isSelected = index == _currentIndex;
          return GestureDetector(
            onTap: () {
              setState(() => _currentIndex = index);
              widget.onThumbnailTap(index);
            },
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
