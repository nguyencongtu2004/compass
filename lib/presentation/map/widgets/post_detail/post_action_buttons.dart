import 'package:flutter/material.dart';
import 'package:minecraft_compass/presentation/core/theme/app_colors.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';

class PostActionButtons extends StatelessWidget {
  const PostActionButtons({
    super.key,
    required this.onMessageTap,
    required this.onCommentTap,
  });

  final VoidCallback onMessageTap;
  final VoidCallback onCommentTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: onMessageTap,
                icon: const Icon(Icons.message),
                label: const Text('Tin nhắn'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary(context),
                  foregroundColor: AppColors.onPrimary(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: OutlinedButton.icon(
                onPressed: onCommentTap,
                icon: const Icon(Icons.comment),
                label: const Text('Bình luận'),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary(context),
                  side: BorderSide(color: AppColors.primary(context)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
