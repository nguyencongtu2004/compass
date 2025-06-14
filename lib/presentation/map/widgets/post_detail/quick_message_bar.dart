import 'package:flutter/material.dart';
import 'package:minecraft_compass/presentation/core/theme/app_colors.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';
import 'package:minecraft_compass/presentation/core/widgets/overlay/overlay_manager.dart';

/// Widget thanh tin nhắn nhanh với 3 icon gợi ý và khả năng mở chat detail
class QuickMessageBar extends StatelessWidget {
  final Function(String message) onQuickMessageSend;
  final VoidCallback onOpenDetailChat;

  const QuickMessageBar({
    super.key,
    required this.onQuickMessageSend,
    required this.onOpenDetailChat,
  });

  // Danh sách các tin nhắn gợi ý với text và emoji tương ứng
  static const List<Map<String, dynamic>> _quickMessages = [
    {
      'text': '❤️',
      'message': '❤️ Tuyệt vời!',
      'emojis': ['❤️', '💖', '😍', '🥰', '💕'],
    },
    {
      'text': '📍',
      'message': '📍 Chỗ này ở đâu vậy?',
      'emojis': ['📍', '🗺️', '🧭', '📌', '🏞️'],
    },
    {
      'text': '👍',
      'message': '👍 Nice!',
      'emojis': ['👍', '👏', '🎉', '✨', '🔥'],
    },
  ];

  void _onEmojiTap(BuildContext context, Map<String, dynamic> messageData) {
    // Hiển thị hiệu ứng emoji bay trước
    OverlayManager.showEmojiRain(
      context,
      emojis: List<String>.from(messageData['emojis']),
      duration: const Duration(seconds: 2),
      emojiCount: 20,
      emojiSize: 50.0,
      onComplete: () {
        // Hiển thị toast thành công với thiết kế mới
        OverlayManager.showSuccess(
          context,
          message: 'Đã gửi tin nhắn thành công! 🎉',
        );
      },
    );

    // Sau đó gửi tin nhắn
    onQuickMessageSend(messageData['message']);
  }

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
                      ),

                      // 3 text gợi ý ở bên phải
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: _quickMessages.map((messageData) {
                          return GestureDetector(
                            onTap: () => _onEmojiTap(context, messageData),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                                vertical: AppSpacing.micro,
                              ),
                              margin: const EdgeInsets.only(
                                left: AppSpacing.micro,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusLg,
                                ),
                                color: Colors.transparent,
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
