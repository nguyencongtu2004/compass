import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../../router/app_routes.dart';
import '../../auth/bloc/auth_bloc.dart';
import 'bloc/conversation_bloc.dart';
import 'widgets/conversation_tile.dart';
import '../chat/bloc/message_bloc_manager.dart';
import '../../../di/injection.dart';

class ConversationListPage extends StatefulWidget {
  const ConversationListPage({super.key});

  @override
  State<ConversationListPage> createState() => _ConversationListPageState();
}

class _ConversationListPageState extends State<ConversationListPage> {
  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  void _loadConversations() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ConversationBloc>().add(
        LoadConversations(authState.user.uid),
      );
    }
  }

  /// Preload data cho các conversations gần đây nhất để tăng tốc độ loading
  void _preloadTopConversations(List<dynamic> conversations) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final messageBlocManager = getIt<MessageBlocManager>();

    // Preload top 3 conversations gần đây nhất
    final topConversations = conversations.take(3);
    for (final conversation in topConversations) {
      final otherUid = conversation.participants.firstWhere(
        (uid) => uid != authState.user.uid,
        orElse: () => '',
      );

      if (otherUid.isNotEmpty) {
        messageBlocManager.preloadConversation(conversation.id, otherUid);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConversationBloc, ConversationState>(
      listenWhen: (previous, current) {
        // Chỉ lắng nghe ConversationDeleted và ConversationError
        // Không lắng nghe ConversationCreated để tránh navigation không mong muốn
        return current is ConversationDeleted || current is ConversationError;
      },
      listener: (context, state) {
        if (state is ConversationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error(context),
            ),
          );
        } else if (state is ConversationDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Đã xóa cuộc trò chuyện'),
              backgroundColor: AppColors.success(context),
            ),
          );
          _loadConversations(); // Reload conversations
        }
      },
      builder: (context, state) {
        if (state is ConversationLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ConversationsLoaded) {
          // Proactive preloading: preload top conversations để giảm loading time
          _preloadTopConversations(state.conversations);

          if (state.conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: AppColors.onSurfaceVariant(context),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Chưa có tin nhắn nào',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.onSurfaceVariant(context),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Bắt đầu trò chuyện với bạn bè từ trang bạn bè',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onSurfaceVariant(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton(
                    onPressed: () => context.push(AppRoutes.friendListRoute),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary(context),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Đi đến bạn bè'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadConversations();
            },
            child: ListView.builder(
              itemCount: state.conversations.length,
              itemBuilder: (context, index) {
                final conversation = state.conversations[index];
                final authState = context.read<AuthBloc>().state;

                if (authState is! AuthAuthenticated) {
                  return const SizedBox.shrink();
                }

                // Tìm UID của người kia (không phải mình)
                final otherUid = conversation.participants.firstWhere(
                  (uid) => uid != authState.user.uid,
                  orElse: () => '',
                );

                return ConversationTile(
                  conversation: conversation,
                  currentUserId: authState.user.uid,
                  onTap: () => context.push(
                    '${AppRoutes.chatRoute}/${conversation.id}',
                    extra: {'otherUid': otherUid},
                  ),
                  onDelete: () => _showDeleteDialog(conversation.id),
                );
              },
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  void _showDeleteDialog(String conversationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa cuộc trò chuyện'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa cuộc trò chuyện này? '
          'Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ConversationBloc>().add(
                DeleteConversation(conversationId),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error(context),
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
