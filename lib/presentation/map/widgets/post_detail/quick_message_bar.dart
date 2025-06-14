import 'package:flutter/material.dart';
import 'package:minecraft_compass/presentation/core/theme/app_colors.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';

/// Widget thanh tin nhắn nhanh với 3 icon gợi ý và khả năng mở chat detail
class QuickMessageBar extends StatelessWidget {
  final Function(String message) onQuickMessageSend;
  final VoidCallback onOpenDetailChat;

  const QuickMessageBar({
    super.key,
    required this.onQuickMessageSend,
    required this.onOpenDetailChat,
  });
  // Danh sách các tin nhắn gợi ý với text
  static const List<Map<String, dynamic>> _quickMessages = [
    {'text': '❤️', 'message': '❤️ Tuyệt vời!'},
    {'text': '📍', 'message': '📍 Chỗ này ở đâu vậy?'},
    {'text': '👍', 'message': '👍 Nice!'},
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.micro,
      ),
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onOpenDetailChat,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground(context),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
                    border: Border.all(color: Colors.transparent),
                  ),
                  child: Row(
                    children: [
                      // Hint text
                      Expanded(
                        child: Text(
                          'Gửi tin nhắn...',
                          style: TextStyle(
                            color: AppColors.onSurface(
                              context,
                            ).withValues(alpha: 0.6),
                            fontSize: 16,
                          ),
                        ),
                      ), // 3 text gợi ý ở bên phải
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: _quickMessages.map((messageData) {
                          return GestureDetector(
                            onTap: () =>
                                onQuickMessageSend(messageData['message']),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                                vertical: AppSpacing.micro,
                              ),
                              margin: const EdgeInsets.only(
                                left: AppSpacing.micro,
                              ),
                              child: Text(
                                messageData['text'],
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
