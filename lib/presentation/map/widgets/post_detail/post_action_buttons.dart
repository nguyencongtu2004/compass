import 'package:flutter/material.dart';
import 'package:minecraft_compass/models/newsfeed_post_model.dart';
import 'package:minecraft_compass/presentation/core/theme/app_colors.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';
import 'package:minecraft_compass/presentation/map/widgets/post_detail/quick_message_bar.dart';
import 'package:minecraft_compass/presentation/map/widgets/post_detail/chat_detail_overlay.dart';

class PostActionButtons extends StatefulWidget {
  const PostActionButtons({
    super.key,
    required this.onMessageSend,
    required this.onCommentTap,
    required this.post,
    this.isShowChatInput = true,
  });

  final Function(String message) onMessageSend;
  final VoidCallback onCommentTap;
  final NewsfeedPost post;
  final bool isShowChatInput;

  @override
  State<PostActionButtons> createState() => _PostActionButtonsState();
}

class _PostActionButtonsState extends State<PostActionButtons> {
  void _openChatDetail() {
    ChatDetailOverlay.show(context, widget.post, widget.onMessageSend);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.isShowChatInput)
          QuickMessageBar(
            onQuickMessageSend: widget.onMessageSend,
            onOpenDetailChat: _openChatDetail,
          ),

        if (false) const SizedBox(height: AppSpacing.xs),

        // Nút bình luận nhỏ ở dưới
        if (false)
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: widget.onCommentTap,
              icon: Icon(
                Icons.comment_outlined,
                size: 16,
                color: AppColors.primary(context),
              ),
              label: Text(
                'Bình luận',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primary(context),
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                minimumSize: const Size(0, 32),
              ),
            ),
          ),
      ],
    );
  }
}
