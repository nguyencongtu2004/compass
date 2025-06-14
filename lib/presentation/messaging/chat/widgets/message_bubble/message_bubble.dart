import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minecraft_compass/models/message_model.dart';
import 'package:minecraft_compass/models/newsfeed_post_model.dart';
import 'package:minecraft_compass/models/user_model.dart';
import 'package:minecraft_compass/presentation/core/theme/app_colors.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';
import 'package:minecraft_compass/presentation/core/theme/app_text_styles.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_avatar.dart';
import 'package:minecraft_compass/presentation/messaging/chat/widgets/message_bubble/post_preview.dart';
import 'package:minecraft_compass/presentation/messaging/chat/widgets/message_bubble/text_message.dart';
import 'package:minecraft_compass/presentation/newfeed/bloc/newsfeed_bloc.dart';
import 'package:minecraft_compass/utils/format_utils.dart';

class MessageBubble extends StatefulWidget {
  final MessageModel message;
  final bool isFromMe;
  final bool showTimestamp;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final bool isLastMessage;
  final UserModel? otherUser;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isFromMe,
    this.showTimestamp = false,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
    this.isLastMessage = false,
    this.otherUser,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  NewsfeedPost? post;
  bool isLoadingPost = false;
  // Cache static để lưu posts đã load
  static final Map<String, NewsfeedPost?> _postCache = {};
  // Method để clear cache khi cần thiết
  // ignore: unused_element
  static void clearPostCache() {
    _postCache.clear();
  }

  @override
  void initState() {
    super.initState();
    if (widget.message.isPost) {
      _loadPost();
    }
  }

  @override
  void didUpdateWidget(MessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Nếu message thay đổi hoặc message type thay đổi, reload post
    if (oldWidget.message.id != widget.message.id ||
        oldWidget.message.isPost != widget.message.isPost ||
        (widget.message.isPost &&
            oldWidget.message.content != widget.message.content)) {
      if (widget.message.isPost) {
        _loadPost();
      } else {
        // Reset post state nếu không còn là post message
        setState(() {
          post = null;
          isLoadingPost = false;
        });
      }
    }
  }

  void _loadPost() async {
    if (widget.message.content.isEmpty) {
      if (mounted) {
        setState(() {
          post = null;
          isLoadingPost = false;
        });
      }
      return;
    } // Kiểm tra cache trước
    if (_postCache.containsKey(widget.message.content)) {
      final cachedPost = _postCache[widget.message.content];
      if (mounted) {
        setState(() {
          post = cachedPost;
          isLoadingPost = false;
        });
      }
      return;
    }

    setState(() {
      isLoadingPost = true;
      post = null; // Reset post trước khi load
    });

    try {
      final loadedPost = await context
          .read<NewsfeedBloc>()
          .newsfeedRepository
          .getPostById(widget.message.content);

      // Cache post đã load
      _postCache[widget.message.content] = loadedPost;

      if (mounted) {
        setState(() {
          post = loadedPost;
          isLoadingPost = false;
        });
      }
    } catch (e) {
      // Log error để debug
      debugPrint('Error loading post ${widget.message.content}: $e');

      // Cache null để tránh retry liên tục
      _postCache[widget.message.content] = null;
      
      if (mounted) {
        setState(() {
          post = null; // Đảm bảo post là null khi có lỗi
          isLoadingPost = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: widget.isFromMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Hiển thị timestamp căn giữa trước tin nhắn
          if (widget.showTimestamp) ...[
            Container(
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant(
                      context,
                    ).withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Text(
                    FormatUtils.formatMessageTime(widget.message.createdAt),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant(context),
                    ),
                  ),
                ),
              ),
            ),
          ],

          // Hiển thị tin nhắn (text hoặc post) với avatar nếu là tin nhắn cuối cùng trong nhóm
          Row(
            mainAxisAlignment: widget.isFromMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Hiển thị avatar cho tin cuối cùng tiên trong nhóm và không phải tin nhắn của mình
              if (!widget.isFromMe && widget.isLastInGroup) ...[
                Container(
                  margin: const EdgeInsets.only(right: AppSpacing.xs), // 4
                  child: CommonAvatar(
                    avatarUrl: widget.otherUser?.avatarUrl,
                    displayName: widget.otherUser?.displayName,
                    radius: 18, // 18 x 2 = 36
                  ),
                ),
              ] else if (!widget.isFromMe &&
                  !widget.isLastInGroup &&
                  !widget.message.isPost) ...[
                // Khoảng trống cho tin nhắn trong nhóm nhưng không phải đầu tiên
                const SizedBox(width: 40), // 40 = avatar 36 + margin 4
              ],

              Flexible(child: _buildMessageContent()),
            ],
          ),

          // Spacing giữa các tin nhắn
          const SizedBox(height: AppSpacing.micro), // 2px
          // Hiển thị avatar nhỏ cho trạng thái đã đọc (chỉ cho tin nhắn cuối cùng trong nhóm)
          if (widget.isFromMe &&
              widget.isLastMessage &&
              widget.message.isRead &&
              widget.otherUser != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.micro),
              child: CommonAvatar(
                avatarUrl: widget.otherUser?.avatarUrl,
                displayName: widget.otherUser?.displayName,
                radius: 8,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageContent() {
    // Nếu là tin nhắn chứa bài đăng, hiển thị preview bài đăng
    if (widget.message.isPost) {
      return Padding(
        padding: EdgeInsets.only(bottom: widget.isFromMe ? 0 : AppSpacing.xs),
        child: PostPreview(
          key: ValueKey(widget.message.id),
          isFromMe: widget.isFromMe,
          post: post,
          isLoadingPost: isLoadingPost,
        ),
      );
    }

    // Nếu là tin nhắn văn bản, hiển thị nội dung tin nhắn
    return TextMessage(
      key: ValueKey(widget.message.id),
      message: widget.message,
      isFromMe: widget.isFromMe,
      isFirstInGroup: widget.isFirstInGroup,
      isLastInGroup: widget.isLastInGroup,
    );
  }
}
