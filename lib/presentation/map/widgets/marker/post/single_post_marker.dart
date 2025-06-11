import 'package:flutter/material.dart';
import 'package:minecraft_compass/models/newsfeed_post_model.dart';
import 'package:minecraft_compass/presentation/core/theme/app_colors.dart';

/// Widget cho single post marker
class SinglePostMarker extends StatelessWidget {
  final NewsfeedPost post;
  final VoidCallback onTap;

  const SinglePostMarker({super.key, required this.post, required this.onTap});
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 120,
        height: 120,
        child: Center(
          child: Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary(context), width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.onSurface(context).withValues(alpha: 0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                post.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, url, error) => Container(
                  color: AppColors.surfaceVariant(context),
                  child: Icon(
                    Icons.broken_image,
                    color: AppColors.onSurfaceVariant(context),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
