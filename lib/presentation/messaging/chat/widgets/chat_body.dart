import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/message_bloc.dart';
import '../../../../models/user_model.dart';
import 'empty_messages_widget.dart';
import 'error_state_widget.dart';
import 'messages_list_widget.dart';

class ChatBody extends StatelessWidget {
  final UserModel? otherUser;
  final bool isLoading;
  final String myUid;
  final ScrollController scrollController;
  final VoidCallback onRetry;

  const ChatBody({
    super.key,
    required this.otherUser,
    required this.isLoading,
    required this.myUid,
    required this.scrollController,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageBloc, MessageState>(
      builder: (context, state) {
        if (state is MessagesLoaded) {
          if (state.messages.isEmpty) {
            return EmptyMessagesWidget(
              otherUser: otherUser,
              isLoading: isLoading,
            );
          }

          return MessagesListWidget(
            messages: state.messages,
            myUid: myUid,
            scrollController: scrollController,
            otherUser: otherUser,
          );
        }

        if (state is MessageError) {
          return ErrorStateWidget(message: state.message, onRetry: onRetry);
        }

        // Hiển thị empty messages thay vì loading để tránh flicker
        return EmptyMessagesWidget(otherUser: otherUser, isLoading: isLoading);
      },
    );
  }
}
