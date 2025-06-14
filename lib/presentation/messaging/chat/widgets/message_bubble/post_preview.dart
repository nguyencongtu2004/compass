import 'package:flutter/material.dart';
import 'package:minecraft_compass/models/newsfeed_post_model.dart';
import 'package:minecraft_compass/presentation/core/theme/app_colors.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';
import 'package:minecraft_compass/presentation/core/theme/app_text_styles.dart';
import 'package:minecraft_compass/presentation/map/widgets/post_detail/post_image_with_caption.dart';

class PostPreview extends StatelessWidget {
  final NewsfeedPost? post;
  final bool isLoadingPost;
  final bool isFromMe;

  const PostPreview({
    super.key,
    this.post,
    required this.isFromMe,
    required this.isLoadingPost,
  });
  @override
  Widget build(BuildContext context) {
    // Nếu đang tải post, hiển thị khung giả lập với hiệu ứng loading
    if (isLoadingPost) {
      return _buildSquareContainer(
        context: context,
        hasShimmer: true,
        child: _buildCenterMessage(
          icon: const SizedBox(
            width: AppSpacing.iconSm,
            height: AppSpacing.iconSm,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
          message: 'Đang tải bài đăng...',
        ),
      );
    }

    // Nếu post là null, hiển thị thông báo lỗi
    // Điều này có thể xảy ra nếu bài đăng đã bị xóa hoặc không còn tồn tại
    if (post == null) {
      return _buildSquareContainer(
        context: context,
        child: _buildCenterMessage(
          icon: const Icon(
            Icons.error_outline,
            size: AppSpacing.iconSm,
            color: Colors.white,
          ),
          message: 'Bài đăng không tồn tại',
        ),
      );
    }

    // Nếu post không null, hiển thị ảnh với caption
    return PostImageWithCaption(post: post!);
  }

  /// Tạo container hình vuông với style chung
  Widget _buildSquareContainer({
    required BuildContext context,
    required Widget child,
    bool hasShimmer = false,
  }) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1, // Định dạng vuông giống như post thực
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant(context).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              // Hiệu ứng shimmer loading (chỉ hiện khi loading)
              if (hasShimmer)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.surfaceVariant(
                            context,
                          ).withValues(alpha: 0.1),
                          AppColors.surfaceVariant(
                            context,
                          ).withValues(alpha: 0.3),
                          AppColors.surfaceVariant(
                            context,
                          ).withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                  ),
                ),
              // Nội dung chính ở giữa
              Center(child: child),
            ],
          ),
        ),
      ),
    );
  }

  /// Tạo message box ở giữa với icon và text
  Widget _buildCenterMessage({required Widget icon, required String message}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSpacing.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: AppSpacing.sm),
          Text(
            message,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
