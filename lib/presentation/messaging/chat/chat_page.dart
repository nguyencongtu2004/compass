import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_appbar.dart';
import '../../core/widgets/common_scaffold.dart';
import 'bloc/message_bloc.dart';
import '../conversation/bloc/conversation_bloc.dart';
import 'widgets/chat_header.dart';
import 'widgets/chat_body.dart';
import 'widgets/message_input.dart';
import '../../../models/message_model.dart';
import '../../../models/user_model.dart';
import '../../../data/managers/message_bloc_manager.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../di/injection.dart';
import '../../auth/bloc/auth_bloc.dart';

class ChatPage extends StatelessWidget {
  final String conversationId;
  final String otherUid;

  const ChatPage({
    super.key,
    required this.conversationId,
    required this.otherUid,
  });

  @override
  Widget build(BuildContext context) {
    final messageBlocManager = getIt<MessageBlocManager>();
    final messageBloc = messageBlocManager.getMessageBloc(conversationId);

    return BlocProvider.value(
      value: messageBloc,
      child: _ChatPageContent(
        conversationId: conversationId,
        otherUid: otherUid,
      ),
    );
  }
}

class _ChatPageContent extends StatefulWidget {
  final String conversationId;
  final String otherUid;

  const _ChatPageContent({
    required this.conversationId,
    required this.otherUid,
  });

  @override
  State<_ChatPageContent> createState() => _ChatPageContentState();
}

class _ChatPageContentState extends State<_ChatPageContent> {
  final ScrollController scrollController = ScrollController();
  final UserRepository userRepository = getIt<UserRepository>();

  UserModel? otherUser;
  bool isLoading = true;
  List<MessageModel> _previousMessages = [];

  String get conversationId => widget.conversationId;
  String get otherUid => widget.otherUid;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    // Load other user info
    try {
      final user = await userRepository.getUserByUid(otherUid);
      if (mounted) {
        setState(() {
          otherUser = user;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }

    // Load messages
    context.read<MessageBloc>().add(LoadMessages(conversationId));

    // Mark messages as read
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<MessageBloc>().add(
        MarkMessagesAsRead(
          conversationId: conversationId,
          myUid: authState.user.uid,
        ),
      );
    }
  }

  void sendMessage(String content) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<MessageBloc>().add(
        SendMessage(
          conversationId: conversationId,
          senderId: authState.user.uid,
          content: content,
          type: MessageType.text,
        ),
      );

      // Scroll to bottom after sending
      scrollToBottom();
    }
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients && mounted) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String getCurrentUserId() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.user.uid;
    }
    return '';
  }

  void _sendMessage(String content) {
    sendMessage(content);
  }

  void _scrollToBottom() {
    scrollToBottom();
  }

  void _loadData() {
    loadData();
  }
  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      appBar: CommonAppbar(
        customWidget: ChatHeader(otherUser: otherUser, isLoading: isLoading,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<MessageBloc, MessageState>(
              listener: (context, state) {
                if (state is MessageError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error(context),
                    ),
                  );
                } else if (state is MessageSent) {
                  _scrollToBottom();
                } else if (state is MessagesLoaded) {
                  // Tự động cuộn xuống khi có tin nhắn mới
                  if (_previousMessages.length != state.messages.length) {
                    _scrollToBottom();
                  }
                  _previousMessages = List.from(state.messages);
                }
              },
              builder: (context, state) {
                return ChatBody(
                  otherUser: otherUser,
                  isLoading: isLoading,
                  myUid: getCurrentUserId(),
                  scrollController: scrollController,
                  onRetry: _loadData,
                );
              },
            ),
          ),
          BlocListener<ConversationBloc, ConversationState>(
            listener: (context, state) {
              if (state is ConversationDeleted) {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa cuộc trò chuyện')),
                );
              }
            },
            child: BlocBuilder<MessageBloc, MessageState>(
              builder: (context, state) {
                // Tắt input khi có lỗi xảy ra
                final isEnabled = state is! MessageError;

                return MessageInput(
                  onSendMessage: _sendMessage,
                  isEnabled: isEnabled,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
