import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_back_button.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common_appbar.dart';
import '../../core/widgets/common_avatar.dart';
import '../../core/widgets/common_scaffold.dart';
import '../../auth/bloc/auth_bloc.dart';
import 'bloc/message_bloc.dart';
import '../conversation/bloc/conversation_bloc.dart';
import 'widgets/message_bubble.dart';
import 'widgets/message_input.dart';
import '../../../models/user_model.dart';
import '../../../models/message_model.dart';
import '../../../data/repositories/user_repository.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;
  final String otherUid;

  const ChatPage({
    super.key,
    required this.conversationId,
    required this.otherUid,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final UserRepository _userRepository = UserRepository();

  UserModel? otherUser;
  bool isLoading = true;
  List<MessageModel> _previousMessages = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    // Load other user info
    try {
      final user = await _userRepository.getUserByUid(widget.otherUid);
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
    context.read<MessageBloc>().add(LoadMessages(widget.conversationId));

    // Mark messages as read
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<MessageBloc>().add(
        MarkMessagesAsRead(
          conversationId: widget.conversationId,
          myUid: authState.user.uid,
        ),
      );
    }
  }

  void _sendMessage(String content) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<MessageBloc>().add(
        SendMessage(
          conversationId: widget.conversationId,
          senderId: authState.user.uid,
          content: content,
          type: MessageType.text,
        ),
      );

      // Scroll to bottom after sending
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && mounted) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      appBar: CommonAppbar(
        customWidget: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonBackButton(),
              const SizedBox(width: AppSpacing.md),

              CommonAvatar(
                radius: 20,
                avatarUrl: otherUser?.avatarUrl ?? '',
                displayName: otherUser?.displayName ?? 'U',
                backgroundColor: AppColors.primary(context),
                textColor: AppColors.onPrimary(context),
              ),
              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: Text(
                  otherUser?.displayName ??
                      (isLoading ? 'Đang tải...' : 'Người dùng'),
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.onSurface(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
            ],
          ),
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
                if (state is MessagesLoaded) {
                  if (state.messages.isEmpty) {
                    return _buildEmptyMessages();
                  }

                  return _buildMessagesList(state.messages);
                }

                if (state is MessageError) {
                  return _buildErrorState(state.message);
                }

                // Hiển thị empty messages thay vì loading để tránh flicker
                return _buildEmptyMessages();
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

  Widget _buildMessagesList(List<MessageModel> messages) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const SizedBox.shrink();
    }

    final myUid = authState.user.uid;

    return ListView.builder(
      controller: _scrollController,
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

        return MessageBubble(
          message: message,
          isFromMe: isFromMe,
          showTimestamp: showTimestamp,
        );
      },
    );
  }

  Widget _buildEmptyMessages() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CommonAvatar(
            radius: 40,
            avatarUrl: otherUser?.avatarUrl ?? '',
            displayName: otherUser?.displayName ?? 'U',
            backgroundColor: AppColors.primary(context),
            textColor: AppColors.onPrimary(context),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Trò chuyện với ${otherUser?.displayName ?? (isLoading ? 'đang tải...' : 'bạn bè')}',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.onSurface(context),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isLoading
                ? 'Đang tải cuộc trò chuyện...'
                : 'Gửi tin nhắn đầu tiên để bắt đầu cuộc trò chuyện',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: AppSpacing.iconXxl * 2,
            color: AppColors.error(context),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Có lỗi xảy ra',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.error(context),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md3),
          TextButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
