import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../core/widgets/common_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

class FriendRequestTile extends StatelessWidget {
  final UserModel requester;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const FriendRequestTile({
    super.key,
    required this.requester,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: ListTile(
        leading: CommonAvatar(
          radius: 20,
          avatarUrl: requester.avatarUrl,
          displayName: requester.displayName,
        ),
        title: Text(
          requester.displayName,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.onSurface(context),
          ),
        ),
        subtitle: Text(
          requester.username.isNotEmpty ? '@${requester.username}' : requester.email,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant(context),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.check, color: AppColors.success(context)),
              onPressed: onAccept,
              tooltip: 'Chấp nhận',
            ),
            IconButton(
              icon: Icon(Icons.close, color: AppColors.error(context)),
              onPressed: onDecline,
              tooltip: 'Từ chối',
            ),
          ],
        ),
      ),
    );
  }
}
