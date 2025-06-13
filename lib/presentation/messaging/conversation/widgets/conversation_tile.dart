import 'package:flutter/material.dart';

import '../../../../di/injection.dart';
import '../../../../models/conversation_model.dart';
import '../../../../models/user_model.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_avatar.dart';
import '../../../../utils/format_utils.dart';

class ConversationTile extends StatefulWidget {
  final ConversationModel conversation;
  final String currentUserId;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
    this.onDelete,
  });

  @override
  State<ConversationTile> createState() => _ConversationTileState();
}

class _ConversationTileState extends State<ConversationTile> {
  UserModel? _otherUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOtherUser();
  }

  void _loadOtherUser() async {
    try {
      // Tìm UID của người kia (không phải current user)
      final otherUid = widget.conversation.participants.firstWhere(
        (uid) => uid != widget.currentUserId,
        orElse: () => '',
      );
      if (otherUid.isNotEmpty) {
        final userRepository =
            getIt<UserRepository>(); // Sử dụng dependency injection
        final user = await userRepository.getUserByUid(otherUid);
        if (mounted) {
          setState(() {
            _otherUser = user;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showContextMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.onSurfaceVariant(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: AppColors.error(context),
              ),
              title: Text(
                'Xóa cuộc trò chuyện',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.error(context),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                widget.onDelete?.call();
              },
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.surfaceVariant(context),
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        title: Container(
          height: 16,
          width: 120,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant(context),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        subtitle: Container(
          height: 12,
          width: 80,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant(context),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );
    }

    final unreadCount =
        widget.conversation.unreadCounts[widget.currentUserId] ?? 0;
    final hasUnread = unreadCount > 0;
    return GestureDetector(
      onLongPress: widget.onDelete != null ? _showContextMenu : null,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: CommonAvatar(
          radius: 28,
          avatarUrl: _otherUser?.avatarUrl ?? '',
          displayName: _otherUser?.displayName ?? 'Unknown',
        ),
        title: Text(
          _otherUser?.displayName ?? 'Unknown User',
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w500,
            color: AppColors.onSurface(context),
          ),
        ),
        subtitle: Text(
          widget.conversation.lastMessage,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
            color: hasUnread
                ? AppColors.onSurface(context)
                : AppColors.onSurfaceVariant(context),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: SizedBox(
          width: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                FormatUtils.getShortTimeAgo(widget.conversation.lastUpdatedAt),
                style: AppTextStyles.bodySmall.copyWith(
                  color: hasUnread
                      ? AppColors.primary(context)
                      : AppColors.onSurfaceVariant(context),
                  fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
              if (hasUnread) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(minWidth: 20),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onPrimary(context),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
        onTap: widget.onTap,
      ),
    );
  }
}
