import 'package:minecraft_compass/config/l10n/localization_extensions.dart';
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
      title: Text(context.l10n.addFriend),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tên: ${widget.user.displayName}'),
          Text('Email: ${widget.user.email}'),
          const SizedBox(height: 8),
          Text(context.l10n.wouldYouLikeToSendAFriendRequest),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _isSendingRequest ? null : _sendFriendRequest,
          child: _isSendingRequest
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(context.l10n.sendInvitation),
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
