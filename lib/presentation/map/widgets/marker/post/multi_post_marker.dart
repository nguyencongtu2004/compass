import 'package:flutter/material.dart';
import 'package:minecraft_compass/models/marker_cluster.dart';
import 'package:minecraft_compass/models/newsfeed_post_model.dart';
import 'package:minecraft_compass/presentation/core/theme/app_colors.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_cached_network_image.dart';
import 'dart:math' as math;

/// Widget cho multi post cluster marker
class MultiPostMarker extends StatelessWidget {
  final MarkerCluster cluster;
  final VoidCallback onTap;

  const MultiPostMarker({
    super.key,
    required this.cluster,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 120, // Tăng kích thước container tổng
        height: 120,
        child: Stack(
          children: [
            // Background với preview images (chồng lên nhau)
            _buildClusterBackground(context),
            // Count badge ở góc phải trên
            Positioned(
              top: 0,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.onPrimary(context),
                    width: 2,
                  ),
                ),
                child: Text(
                  '${cluster.count}',
                  style: TextStyle(
                    color: AppColors.onPrimary(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClusterBackground(BuildContext context) {
    // Hiển thị preview của các images trong cluster (tối đa 4 ảnh)
    final visiblePosts = cluster.posts.take(4).toList();

    return SizedBox(
      width: 120, // Tăng kích thước area chứa ảnh
      height: 120,
      child: Stack(
        children: [
          // Hiển thị các ảnh chồng lên nhau và xòe ra
          for (int i = visiblePosts.length - 1; i >= 0; i--)
            _buildStackedImage(
              context,
              visiblePosts[i],
              i,
              visiblePosts.length,
            ),
        ],
      ),
    );
  }

  Widget _buildStackedImage(
    BuildContext context,
    NewsfeedPost post,
    int index,
    int total,
  ) {
    // Tính toán góc xoay và offset cho mỗi ảnh
    double rotation = 0;
    double offsetX = 0;
    double offsetY = 0;
    double scale = 1.0;

    if (total > 1) {
      // Các ảnh phía sau sẽ có góc xoay và offset khác nhau
      switch (index) {
        case 0: // Ảnh cuối cùng (phía sau nhất)
          rotation = -15 * (math.pi / 180); // -15 độ
          offsetX = -15;
          offsetY = -12;
          scale = 0.85;
          break;
        case 1: // Ảnh thứ 3
          rotation = -8 * (math.pi / 180); // -8 độ
          offsetX = -8;
          offsetY = -6;
          scale = 0.9;
          break;
        case 2: // Ảnh thứ 2
          rotation = 5 * (math.pi / 180); // 5 độ
          offsetX = 4;
          offsetY = -4;
          scale = 0.95;
          break;
        case 3: // Ảnh đầu tiên (phía trước nhất)
          rotation = 0;
          offsetX = 0;
          offsetY = 0;
          scale = 1.0;
          break;
      }
    }

    return Positioned(
      // Center với offset, tăng kích thước ảnh
      left: 60 + offsetX - (80 * scale) / 2,
      // Center với offset
      top: 60 + offsetY - (80 * scale) / 2, 
      child: Hero(
        tag: '${post.id}_$index',
        child: Transform.rotate(
          angle: rotation,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 80, // Tăng kích thước ảnh từ 60 lên 80
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white,
                  width: 4, // Tăng độ dày border
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 6,
                    spreadRadius: 2,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CommonCachedNetworkImage(
                  imageUrl: post.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
