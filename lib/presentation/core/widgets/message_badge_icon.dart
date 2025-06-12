import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minecraft_compass/presentation/core/theme/app_colors.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';
import 'package:minecraft_compass/presentation/core/theme/app_text_styles.dart';
import 'package:minecraft_compass/presentation/messaging/conversation/bloc/conversation_bloc.dart';

class MessageBadgeIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;

  const MessageBadgeIcon({
    super.key,
    required this.icon,
    this.onTap,
    this.size = AppSpacing.md4,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Icon(icon, size: size),
          BlocBuilder<ConversationBloc, ConversationState>(
            builder: (context, state) {
              int unreadCount = 0;
              if (state is ConversationsLoaded) {
                unreadCount = state.totalUnreadCount;
              }

              if (unreadCount == 0) {
                return const SizedBox.shrink();
              }

              return Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.onError(context),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
