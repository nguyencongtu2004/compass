import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../core/widgets/common_avatar.dart';
import '../../core/theme/app_colors.dart';

class FriendTile extends StatelessWidget {
  final UserModel friend;
  final VoidCallback onRemove;

  const FriendTile({super.key, required this.friend, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CommonAvatar(
        radius: 20,
        avatarUrl: friend.avatarUrl,
        displayName: friend.displayName,
      ),
      title: Text(friend.displayName),
      subtitle: Text(friend.email),
      trailing: IconButton(
        icon: Icon(Icons.close, color: AppColors.error(context), size: 20),
        onPressed: onRemove,
        tooltip: 'Xóa bạn bè',
      ),
    );
  }
}
