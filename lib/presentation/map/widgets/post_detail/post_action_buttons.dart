import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minecraft_compass/models/newsfeed_post_model.dart';
import 'package:minecraft_compass/presentation/map/bloc/map_bloc.dart';
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
    ChatDetailOverlay.show(context, widget.post, widget.onMessageSend).then(
      (_) => context.read<MapBloc>().add(
        const MapPostDetailVisibilityChanged(true),
      ),
    );
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
      ],
    );
  }
}
