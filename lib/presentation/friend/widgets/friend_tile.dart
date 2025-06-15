import 'package:minecraft_compass/config/l10n/localization_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../models/user_model.dart';
import '../../core/widgets/common_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../../router/app_routes.dart';
import '../../../data/repositories/message_repository.dart';
import '../../../di/injection.dart';

class FriendTile extends StatelessWidget {
  final UserModel friend;
  final VoidCallback onRemove;

  const FriendTile({super.key, required this.friend, required this.onRemove});

  void _startConversation(BuildContext context) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      try {
        // Tạo conversation trực tiếp để tránh multiple listeners
        final messageRepository = getIt<MessageRepository>();
        final conversation = await messageRepository.createOrGetConversation(
          authState.user.uid,
          friend.uid,
        );

        // Navigate to chat page ngay lập tức
        if (context.mounted) {
          context.push(
            '${AppRoutes.chatRoute}/${conversation.id}',
            extra: {'otherUid': friend.uid},
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể tạo cuộc trò chuyện: $e'),
              backgroundColor: AppColors.error(context),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      leading: CommonAvatar(
        radius: 28,
        avatarUrl: friend.avatarUrl,
        displayName: friend.displayName,
      ),
      title: Text(
        friend.displayName,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface(context),
        ),
      ),
      subtitle: Text(
        friend.email,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.onSurfaceVariant(context),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Message button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: Icon(
                Icons.message,
                color: AppColors.primary(context),
                size: 20,
              ),
              onPressed: () => _startConversation(context),
              tooltip: context.l10n.textMessage,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Remove button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.error(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: Icon(
                Icons.person_remove,
                color: AppColors.error(context),
                size: 20,
              ),
              onPressed: onRemove,
              tooltip: context.l10n.deleteFriends,
            ),
          ),
        ],
      ),
    );
  }
}
