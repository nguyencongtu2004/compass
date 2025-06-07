import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/user_model.dart';
import '../bloc/friend_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../core/theme/app_colors.dart';

class RemoveFriendDialog extends StatelessWidget {
  final UserModel friend;

  const RemoveFriendDialog({super.key, required this.friend});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Xóa bạn bè'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bạn có chắc chắn muốn xóa ${friend.displayName} khỏi danh sách bạn bè?',
          ),
          const SizedBox(height: 8),
          const Text(
            'Hành động này sẽ xóa bạn khỏi danh sách bạn bè của nhau.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error(context),
            foregroundColor: AppColors.onError(context),
          ),
          onPressed: () {
            Navigator.pop(context);
            _removeFriend(context);
          },
          child: const Text('Xóa'),
        ),
      ],
    );
  }

  void _removeFriend(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<FriendBloc>().add(
        RemoveFriend(myUid: authState.user.uid, friendUid: friend.uid),
      );

      // Hiển thị thông báo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã xóa bạn bè'),
          backgroundColor: AppColors.primary(context),
        ),
      );
    }
  }
}
