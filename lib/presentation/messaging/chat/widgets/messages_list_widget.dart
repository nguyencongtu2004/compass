import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../../models/message_model.dart';
import 'message_bubble.dart';

class MessagesListWidget extends StatelessWidget {
  final List<MessageModel> messages;
  final String myUid;
  final ScrollController scrollController;

  const MessagesListWidget({
    super.key,
    required this.messages,
    required this.myUid,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isFromMe = message.senderId == myUid;

        // Show timestamp for first message or messages with >30 minutes gap
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

        return MessageBubble(
          message: message,
          isFromMe: isFromMe,
          showTimestamp: showTimestamp,
        );
      },
    );
  }
}
