import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:minecraft_compass/models/user_model.dart';
import 'package:minecraft_compass/presentation/auth/bloc/auth_bloc.dart';
import 'package:minecraft_compass/presentation/core/theme/app_colors.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';
import 'package:minecraft_compass/presentation/core/theme/app_text_styles.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_avatar.dart';
import 'package:minecraft_compass/presentation/messaging/conversation/bloc/conversation_bloc.dart';
import 'package:minecraft_compass/router/app_routes.dart';

class FriendActionPopup extends StatelessWidget {
  final UserModel friend;
  final VoidCallback? onDismiss;

  const FriendActionPopup({super.key, required this.friend, this.onDismiss});

  static Future<void> show(BuildContext context, UserModel friend) {
    return showDialog(
      context: context,
      builder: (context) => FriendActionPopup(friend: friend),
    );
  }

  void _onDirections(BuildContext context) {
    Navigator.of(context).pop();

    if (friend.currentLocation?.latitude != null &&
        friend.currentLocation?.longitude != null) {
      // Điều hướng đến trang compass với tọa độ bạn bè
      context.push(
        '${AppRoutes.compassRoute}?lat=${friend.currentLocation!.latitude}&lng=${friend.currentLocation!.longitude}&friend=${Uri.encodeComponent(friend.displayName)}',
      );
    } else {
      // Hiển thị thông báo lỗi nếu không có tọa độ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${friend.displayName} chưa có thông tin vị trí'),
          backgroundColor: AppColors.error(context),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      );
    }
  }

  void _onMessage(BuildContext context) {
    Navigator.of(context).pop();

    // Get current user from AuthBloc
    final authState = context.read<AuthBloc>().state;

    if (authState is! AuthAuthenticated) {
      _showErrorSnackBar(context, 'Bạn cần đăng nhập để gửi tin nhắn');
      return;
    }

    final currentUserUid = authState.user.uid;

    // Show dialog with BlocListener to handle conversation creation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) =>
          BlocListener<ConversationBloc, ConversationState>(
            listener: (context, state) {
              if (state is ConversationCreated) {
                // Close loading dialog
                Navigator.of(dialogContext).pop();

                // Navigate to chat
                context.push(
                  '${AppRoutes.chatRoute}/${state.conversation.id}',
                  extra: {'otherUid': friend.uid},
                );
              } else if (state is ConversationError) {
                // Close loading dialog
                Navigator.of(dialogContext).pop();

                // Show error
                _showErrorSnackBar(context, state.message);
              }
            },
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface(dialogContext),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Đang tạo cuộc trò chuyện...',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurface(dialogContext),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    ); // Create or get conversation after showing dialog
    context.read<ConversationBloc>().add(
      CreateOrGetConversation(myUid: currentUserUid, otherUid: friend.uid),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error(context),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header với avatar và tên bạn bè
            Row(
              children: [
                CommonAvatar(
                  radius: 25,
                  avatarUrl: friend.avatarUrl,
                  displayName: friend.displayName,
                  borderSpacing: 2,
                  borderColor: AppColors.primary(context),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friend.displayName,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.onSurface(context),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (friend.currentLocation?.latitude != null &&
                          friend.currentLocation?.longitude != null)
                        Text(
                          'Vị trí có sẵn',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary(context),
                          ),
                        )
                      else
                        Text(
                          'Chưa có vị trí',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.error(context),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Divider
            Divider(
              color: AppColors.outline(context).withValues(alpha: 0.2),
              height: 1,
            ),

            const SizedBox(height: AppSpacing.md),

            // Action buttons
            Column(
              children: [
                // Nút chỉ đường
                _ActionButton(
                  icon: Icons.navigation,
                  label: 'Chỉ đường',
                  subtitle:
                      friend.currentLocation?.latitude != null &&
                          friend.currentLocation?.longitude != null
                      ? 'Điều hướng đến vị trí của ${friend.displayName}'
                      : 'Không thể chỉ đường - chưa có vị trí',
                  onTap:
                      friend.currentLocation?.latitude != null &&
                          friend.currentLocation?.longitude != null
                      ? () => _onDirections(context)
                      : null,
                  isEnabled:
                      friend.currentLocation?.latitude != null &&
                      friend.currentLocation?.longitude != null,
                ),

                const SizedBox(height: AppSpacing.sm),

                // Nút nhắn tin
                // _ActionButton(
                //   icon: Icons.message,
                //   label: 'Nhắn tin',
                //   subtitle: 'Gửi tin nhắn cho ${friend.displayName}',
                //   onTap: () => _onMessage(context),
                //   isEnabled: true,
                // ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Nút đóng
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.onSurface(
                  context,
                ).withValues(alpha: 0.6),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
              ),
              child: Text('Đóng', style: AppTextStyles.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isEnabled;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.onTap,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isEnabled
                ? AppColors.primaryContainer(context).withValues(alpha: 0.1)
                : AppColors.surfaceVariant(context).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: isEnabled
                  ? AppColors.primary(context).withValues(alpha: 0.2)
                  : AppColors.outline(context).withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isEnabled
                      ? AppColors.primary(context)
                      : AppColors.surfaceVariant(context),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  icon,
                  color: isEnabled
                      ? AppColors.onPrimary(context)
                      : AppColors.onSurface(context).withValues(alpha: 0.4),
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: isEnabled
                            ? AppColors.onSurface(context)
                            : AppColors.onSurface(
                                context,
                              ).withValues(alpha: 0.4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isEnabled
                            ? AppColors.onSurface(
                                context,
                              ).withValues(alpha: 0.7)
                            : AppColors.onSurface(
                                context,
                              ).withValues(alpha: 0.4),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isEnabled)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.onSurface(context).withValues(alpha: 0.4),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
