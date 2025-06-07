import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/user_model.dart';
import '../bloc/friend_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';

class AddFriendDialog extends StatefulWidget {
  final UserModel user;

  const AddFriendDialog({super.key, required this.user});

  @override
  State<AddFriendDialog> createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<AddFriendDialog> {
  bool _isSendingRequest = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm bạn'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tên: ${widget.user.displayName}'),
          Text('Email: ${widget.user.email}'),
          const SizedBox(height: 8),
          const Text('Bạn có muốn gửi lời mời kết bạn?'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _isSendingRequest ? null : _sendFriendRequest,
          child: _isSendingRequest
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Gửi lời mời'),
        ),
      ],
    );
  }

  void _sendFriendRequest() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      setState(() {
        _isSendingRequest = true;
      });

      context.read<FriendBloc>().add(
        SendFriendRequest(fromUid: authState.user.uid, toUid: widget.user.uid),
      );

      Navigator.pop(context);
    }
  }
}
