import 'package:flutter/material.dart';
import 'package:minecraft_compass/models/newsfeed_post_model.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';
import 'package:minecraft_compass/presentation/map/widgets/post_detail/post_action_buttons.dart';
import 'package:minecraft_compass/presentation/map/widgets/post_detail/post_header.dart';
import 'package:minecraft_compass/presentation/map/widgets/post_detail/post_image_with_caption.dart';
import 'package:minecraft_compass/presentation/map/widgets/post_detail/post_user_info.dart';
import 'package:minecraft_compass/presentation/map/widgets/post_detail/post_thumbnail_strip.dart';

/// Modern unified overlay hiển thị chi tiết post/cluster với giao diện hiện đại
class ModernPostOverlay extends StatefulWidget {
  final List<NewsfeedPost> posts;

  const ModernPostOverlay({super.key, required this.posts});

  /// Static method để hiển thị overlay cho single post
  static void showSinglePost(BuildContext context, NewsfeedPost post) =>
      show(context, [post]);

  /// Static method để hiển thị overlay cho cluster posts
  static void showMultiplePosts(
    BuildContext context,
    List<NewsfeedPost> posts,
  ) => show(context, posts);

  /// Static method chung để hiển thị overlay
  static void show(BuildContext context, List<NewsfeedPost> posts) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false, // Route trong suốt
        barrierColor: Colors.black.withValues(alpha: 0.7),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: ModernPostOverlay(posts: posts),
          );
        },
      ),
    );
  }

  @override
  State<ModernPostOverlay> createState() => _ModernPostOverlayState();
}

class _ModernPostOverlayState extends State<ModernPostOverlay> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) => setState(() => _currentIndex = index);

  void _onThumbnailTap(int index) => _pageController.animateToPage(
    index,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOutCubicEmphasized,
  );

  void _sendMessage(BuildContext context) {
    // TODO: Implement send message functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chức năng gửi tin nhắn sẽ được triển khai sau'),
      ),
    );
  }

  void _addComment(BuildContext context) {
    // TODO: Implement add comment functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chức năng bình luận sẽ được triển khai sau'), 
      ),
    );
  }

  bool get _hasMultiplePosts => widget.posts.length > 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background tap to close
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              color: Colors.transparent,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // Content
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                top: AppSpacing.toolBarHeight(context),
                // top: AppSpacing.lg,
                bottom: AppSpacing.lg2,
              ),
              child: Column(
                children: [
                  // Header cố định ở trên
                  PostHeader(onCloseTap: () => Navigator.of(context).pop()),
                  const SizedBox(height: AppSpacing.sm),

                  // Content chính
                  Expanded(child: _buildContent(context)),

                  // Thumbnail strip (chỉ hiện khi có nhiều posts)
                  SizedBox(
                    height: 80,
                    child: _hasMultiplePosts
                        ? PostThumbnailStrip(
                            posts: widget.posts,
                            currentIndex: _currentIndex,
                            onThumbnailTap: _onThumbnailTap,
                          )
                        : SizedBox(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_hasMultiplePosts) {
      return PageView.builder(
        physics: const BouncingScrollPhysics(),
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: widget.posts.length,
        itemBuilder: (context, index) {
          final post = widget.posts[index];
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              children: [
                // User info cố định ở trên gần ảnh
                PostUserInfo(post: post),
                const SizedBox(height: AppSpacing.md),

                // Image container với caption đè lên
                PostImageWithCaption(post: post, index: index),

                // Action buttons ở dưới ảnh
                const SizedBox(height: AppSpacing.md),
                PostActionButtons(
                  onMessageTap: () => _sendMessage(context),
                  onCommentTap: () => _addComment(context),
                ),
              ],
            ),
          );
        },
      );
    } else {
      // Single post layout
      final post = widget.posts.first;
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          children: [
            // User info cố định ở trên gần ảnh
            PostUserInfo(post: post),
            const SizedBox(height: AppSpacing.md),

            // Image container với caption đè lên
            PostImageWithCaption(post: post, index: 0),

            // Action buttons ở dưới ảnh
            const SizedBox(height: AppSpacing.md),
            PostActionButtons(
              onMessageTap: () => _sendMessage(context),
              onCommentTap: () => _addComment(context),
            ),
          ],
        ),
      );
    }
  }
}
