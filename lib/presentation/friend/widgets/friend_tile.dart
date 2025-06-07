import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../core/widgets/common_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class FriendTile extends StatelessWidget {
  final UserModel friend;
  final VoidCallback onRemove;

  const FriendTile({super.key, required this.friend, required this.onRemove});
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
      trailing: Container(
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
          tooltip: 'Xóa bạn bè',
        ),
      ),
    );
  }
}
