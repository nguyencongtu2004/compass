import 'package:flutter/material.dart';
import 'package:minecraft_compass/models/newsfeed_post_model.dart';
import 'package:minecraft_compass/presentation/core/theme/app_colors.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';
import 'package:minecraft_compass/presentation/map/widgets/post_detail/post_image_with_caption.dart';
import 'package:minecraft_compass/presentation/messaging/chat/widgets/message_input.dart';

/// Overlay trang chat chi tiết với post và thanh tin nhắn đầy đủ
class ChatDetailOverlay extends StatefulWidget {
  final NewsfeedPost post;
  final Function(String message) onSendMessage;

  const ChatDetailOverlay({
    super.key,
    required this.post,
    required this.onSendMessage,
  });

  /// Static method để hiển thị overlay
  static Future<void> show(
    BuildContext context,
    NewsfeedPost post,
    Function(String message) onSendMessage,
  ) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        // opaque: false, // Route trong suốt
        barrierColor: AppColors.surface(context),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: ChatDetailOverlay(post: post, onSendMessage: onSendMessage),
          );
        },
      ),
    );
  }

  @override
  State<ChatDetailOverlay> createState() => _ChatDetailOverlayState();
}

class _ChatDetailOverlayState extends State<ChatDetailOverlay>
    with WidgetsBindingObserver {
  double _keyboardHeight = 0;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Đóng overlay một cách an toàn, tránh pop nhiều lần
  void _closeOverlay() {
    if (_isClosing || !mounted) return;

    _isClosing = true;
    Navigator.of(context).pop();
  }
  
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final newKeyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // Nếu đã đang đóng thì không làm gì nữa
    if (_isClosing) {
      _keyboardHeight = newKeyboardHeight;
      return;
    }

    // Kiểm tra xem chiều cao có giảm không (chỉ cần 1 lần)
    if (newKeyboardHeight < _keyboardHeight && _keyboardHeight > 50) {
      _closeOverlay();
    }

    _keyboardHeight = newKeyboardHeight;
  }
  void _handleSendMessage(String message) {
    // Gửi tin nhắn
    widget.onSendMessage(message);

    // Đóng overlay và quay lại
    _closeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true, // Cho phép resize khi bàn phím hiện
      body: Stack(
        children: [
          // Background trong suốt (có thể chạm để đóng)
          GestureDetector(
            onTap: _closeOverlay,
            child: Container(
              color: Colors.transparent,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // Content chiếm toàn bộ màn hình giống ModernPostOverlay
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                bottom: AppSpacing.sm,
              ),
              child: Column(
                children: [
                  // Post content mở rộng toàn màn hình
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: _buildPostContent(context),
                    ),
                  ),

                  // Thanh tin nhắn ở dưới cùng
                  _buildMessageInput(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: _closeOverlay,
        icon: const Icon(Icons.close, color: Colors.white, size: 20),
        style: IconButton.styleFrom(
          backgroundColor: Colors.transparent,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(AppSpacing.xs),
          minimumSize: const Size(32, 32),
        ),
      ),
    );
  }

  Widget _buildPostContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: PostImageWithCaption(post: widget.post),
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(width: AppSpacing.sm), // Khoảng cách bên trái
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _buildCloseButton(context),
          ),
          Expanded(
            child: MessageInput(
              onSendMessage: _handleSendMessage,
              isEnabled: true,
              backgroundColor: Colors.transparent,
              autoFocus: true, // Tự động focus để mở bàn phím
            ),
          ),
        ],
      ),
    );
  }
}
