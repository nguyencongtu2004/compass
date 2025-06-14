import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../../models/message_model.dart';
import '../../../../models/user_model.dart';
import 'message_bubble/message_bubble.dart';

class MessagesListWidget extends StatelessWidget {
  final List<MessageModel> messages;
  final String myUid;
  final ScrollController scrollController;
  final UserModel? otherUser;

  const MessagesListWidget({
    super.key,
    required this.messages,
    required this.myUid,
    required this.scrollController,
    this.otherUser,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      cacheExtent: double.infinity,
      controller: scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isFromMe =
            message.senderId ==
            myUid; // Show timestamp for first message or messages with >30 minutes gap
        bool showTimestamp = false;
        if (index == messages.length - 1) {
          // Always show timestamp for the oldest message
          showTimestamp = true;
        } else {
          final nextMessage = messages[index + 1];
          final timeDiff = nextMessage.createdAt.difference(message.createdAt);
          if (timeDiff.inMinutes >= 30) {
            showTimestamp = true;
          }
        }

        // Determine if message is first in group
        final isFirstInGroup = _isFirstInGroup(index);

        // Determine if message is last in group
        final isLastInGroup = _isLastInGroup(index);
        return MessageBubble(
          key: ValueKey(message.id),
          message: message,
          isFromMe: isFromMe,
          showTimestamp: showTimestamp,
          isFirstInGroup: isFirstInGroup,
          isLastInGroup: isLastInGroup,
          otherUser: otherUser,
          isLastMessage: index == 0, // Always last message in the list
        );
      },
    );
  }

  // Kiểm tra xem tin nhắn có phải là tin nhắn đầu tiên của một nhóm
  bool _isFirstInGroup(int index) {
    if (index == messages.length - 1) {
      // Tin nhắn cũ nhất luôn là đầu tiên của một nhóm
      return true;
    }

    final message = messages[index];
    // Vì danh sách tin nhắn được đảo ngược
    final previousMessage = messages[index + 1];

    // Nếu tin nhắn trước đó từ người khác, hoặc khoảng cách thời gian > 5 phút
    return message.senderId != previousMessage.senderId ||
        previousMessage.createdAt.difference(message.createdAt).inMinutes >= 5;
  }

  // Kiểm tra xem tin nhắn có phải là tin nhắn cuối cùng của một nhóm
  bool _isLastInGroup(int index) {
    if (index == 0) {
      // Tin nhắn mới nhất luôn là cuối cùng của một nhóm
      return true;
    }

    final message = messages[index];
    // Vì danh sách tin nhắn được đảo ngược
    final nextMessage = messages[index - 1];
    // Nếu tin nhắn tiếp theo từ người khác, hoặc khoảng cách thời gian > 5 phút
    return message.senderId != nextMessage.senderId ||
        message.createdAt.difference(nextMessage.createdAt).inMinutes >= 5;
  }
}
