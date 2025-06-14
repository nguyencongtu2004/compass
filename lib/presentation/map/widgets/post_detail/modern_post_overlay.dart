import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minecraft_compass/di/injection.dart';
import 'package:minecraft_compass/models/newsfeed_post_model.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';
import 'package:minecraft_compass/presentation/map/widgets/post_detail/post_action_buttons.dart';
import 'package:minecraft_compass/presentation/map/widgets/post_detail/post_header.dart';
import 'package:minecraft_compass/presentation/map/widgets/post_detail/post_image_with_caption.dart';
import 'package:minecraft_compass/presentation/map/widgets/post_detail/post_user_info.dart';
import 'package:minecraft_compass/presentation/map/widgets/post_detail/post_thumbnail_strip.dart';
import 'package:minecraft_compass/presentation/auth/bloc/auth_bloc.dart';
import 'package:minecraft_compass/models/message_model.dart';
import 'package:minecraft_compass/presentation/core/theme/app_colors.dart';
import 'package:minecraft_compass/data/repositories/message_repository.dart';
import 'package:minecraft_compass/presentation/map/bloc/map_bloc.dart';

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
    // Thông báo MapBloc rằng post detail đang được hiển thị
    context.read<MapBloc>().add(const MapPostDetailVisibilityChanged(true));
    
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
    ).then((_) {
      // Thông báo MapBloc rằng post detail đã được đóng
      context.read<MapBloc>().add(const MapPostDetailVisibilityChanged(false));
    });
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
  void _sendMessage(BuildContext context, String userMessage) {
    final currentPost = widget.posts[_currentIndex];
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticated) {
      final myUid = authState.user.uid;
      final postAuthorUid = currentPost.userId;

      // Không cho phép gửi tin nhắn cho chính mình
      if (myUid == postAuthorUid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Bạn không thể gửi tin nhắn cho chính mình'),
            backgroundColor: AppColors.error(context),
          ),
        );
        return;
      }

      // Tạo conversation và gửi 2 messages
      _createConversationAndSendMessages(
        context,
        myUid,
        postAuthorUid,
        currentPost,
        userMessage,
      );
    }
  }

  void _createConversationAndSendMessages(
    BuildContext context,
    String myUid,
    String postAuthorUid,
    NewsfeedPost currentPost,
    String userMessage,
  ) async {
    try {
      // Tạo conversation trực tiếp không qua bloc để tránh multiple listeners
      final messageRepository = getIt<MessageRepository>();
      final conversation = await messageRepository.createOrGetConversation(
        myUid,
        postAuthorUid,
      );

      // Gửi message chứa post trước
      await messageRepository.sendMessage(
        conversationId: conversation.id,
        senderId: myUid,
        content: currentPost.id, // Post ID as content
        type: MessageType.post,
      );

      // Gửi message của người dùng sau
      await messageRepository.sendMessage(
        conversationId: conversation.id,
        senderId: myUid,
        content: userMessage,
        type: MessageType.text,
      );

      // Navigate to chat
      // Navigator.of(context).pop(); // Close overlay first
      // context.push(
      //   '${AppRoutes.chatRoute}/${conversation.id}',
      //   extra: {'otherUid': postAuthorUid},
      // );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tạo cuộc trò chuyện: $e'),
          backgroundColor: AppColors.error(context),
        ),
      );
    }
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // User info cố định ở trên gần ảnh
                  PostUserInfo(post: post),
                  const SizedBox(height: AppSpacing.md),

                  // Image container với caption đè lên
                  PostImageWithCaption(post: post),
                  // Action buttons ở dưới ảnh
                  const SizedBox(height: AppSpacing.md),
                  Builder(
                    builder: (context) {
                      final authState = context.read<AuthBloc>().state;
                      final bool isMyPost;
                      if (authState is AuthAuthenticated) {
                        final myUid = authState.user.uid;
                        final postAuthorUid = post.userId;
                        isMyPost = myUid == postAuthorUid;
                      } else {
                        // Chưa đăng nhập thì không phải post của mình
                        isMyPost = false;
                      }
                      return PostActionButtons(
                        post: post,
                        isShowChatInput: !isMyPost,
                        onMessageSend: (message) =>
                            _sendMessage(context, message),
                        onCommentTap: () => _addComment(context),
                      );
                    },
                  ),
                ],
              ),
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              // User info cố định ở trên gần ảnh
              PostUserInfo(post: post),
              const SizedBox(
                height: AppSpacing.md,
              ), // Image container với caption đè lên
              PostImageWithCaption(post: post),

              // Action buttons ở dưới ảnh
              const SizedBox(height: AppSpacing.md),
              Builder(
                builder: (context) {
                  final authState = context.read<AuthBloc>().state;
                  final bool isMyPost;
                  if (authState is AuthAuthenticated) {
                    final myUid = authState.user.uid;
                    final postAuthorUid = post.userId;
                    isMyPost = myUid == postAuthorUid;
                  } else {
                    // Chưa đăng nhập thì không phải post của mình
                    isMyPost = false;
                  }
                  return PostActionButtons(
                    post: post,
                    isShowChatInput: !isMyPost,
                    onMessageSend: (message) => _sendMessage(context, message),
                    onCommentTap: () => _addComment(context),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }
  }
}
