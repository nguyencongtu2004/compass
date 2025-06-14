import 'package:flutter/material.dart';
import 'package:minecraft_compass/models/message_model.dart';
import 'package:minecraft_compass/presentation/core/theme/app_colors.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';
import 'package:minecraft_compass/presentation/core/theme/app_text_styles.dart';

class TextMessage extends StatelessWidget {
  final MessageModel message;
  final bool isFromMe;
  final bool isFirstInGroup;
  final bool isLastInGroup;

  const TextMessage({
    super.key,
    required this.message,
    required this.isFromMe,
    required this.isFirstInGroup,
    required this.isLastInGroup,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.7,
      ),
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isFromMe
                ? AppColors.primary(context)
                : AppColors.inputBackground(context), // Sử dụng màu chung
            borderRadius: _getBorderRadius(),
          ),
          child: Text(
            message.content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isFromMe
                  ? AppColors.onPrimary(context)
                  : AppColors.onSurface(context),
            ),
          ),
        ),
      ),
    );
  }

  /// Lấy BorderRadius dựa trên vị trí của tin nhắn trong nhóm
  /// - Nếu là tin nhắn của mình, bo góc bên phải
  /// - Nếu là tin nhắn của người khác, bo góc bên trái
  BorderRadius _getBorderRadius() {
    const double largeRadius = AppSpacing.radiusXxl;
    const double smallRadius = AppSpacing.radiusSm;

    if (isFromMe) {
      // Tin nhắn của tôi (bên phải)
      if (isFirstInGroup && isLastInGroup) {
        // Tin nhắn duy nhất trong nhóm
        return BorderRadius.circular(largeRadius);
      } else if (isFirstInGroup) {
        // Tin nhắn đầu tiên trong nhóm
        return const BorderRadius.only(
          topLeft: Radius.circular(largeRadius),
          topRight: Radius.circular(largeRadius),
          bottomLeft: Radius.circular(largeRadius),
          bottomRight: Radius.circular(smallRadius),
        );
      } else if (isLastInGroup) {
        // Tin nhắn cuối cùng trong nhóm
        return const BorderRadius.only(
          topLeft: Radius.circular(largeRadius),
          topRight: Radius.circular(smallRadius),
          bottomLeft: Radius.circular(largeRadius),
          bottomRight: Radius.circular(largeRadius),
        );
      } else {
        // Tin nhắn ở giữa nhóm
        return const BorderRadius.only(
          topLeft: Radius.circular(largeRadius),
          topRight: Radius.circular(smallRadius),
          bottomLeft: Radius.circular(largeRadius),
          bottomRight: Radius.circular(smallRadius),
        );
      }
    } else {
      // Tin nhắn của người khác (bên trái)
      if (isFirstInGroup && isLastInGroup) {
        // Tin nhắn duy nhất trong nhóm
        return BorderRadius.circular(largeRadius);
      } else if (isFirstInGroup) {
        // Tin nhắn đầu tiên trong nhóm
        return const BorderRadius.only(
          topLeft: Radius.circular(largeRadius),
          topRight: Radius.circular(largeRadius),
          bottomLeft: Radius.circular(smallRadius),
          bottomRight: Radius.circular(largeRadius),
        );
      } else if (isLastInGroup) {
        // Tin nhắn cuối cùng trong nhóm
        return const BorderRadius.only(
          topLeft: Radius.circular(smallRadius),
          topRight: Radius.circular(largeRadius),
          bottomLeft: Radius.circular(largeRadius),
          bottomRight: Radius.circular(largeRadius),
        );
      } else {
        // Tin nhắn ở giữa nhóm
        return const BorderRadius.only(
          topLeft: Radius.circular(smallRadius),
          topRight: Radius.circular(largeRadius),
          bottomLeft: Radius.circular(smallRadius),
          bottomRight: Radius.circular(largeRadius),
        );
      }
    }
  }
}
