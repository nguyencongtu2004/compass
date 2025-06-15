import 'package:minecraft_compass/config/l10n/localization_extensions.dart';
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
      title: Text(context.l10n.deleteFriends),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n
                .areYouSureYouWantToRemoveDisplaynameFromYourFriendsList(
                  friend.displayName,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.thisActionWillRemoveYouFromEachOtherSFriendsList,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
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
          child: Text(context.l10n.delete),
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
          content: Text(context.l10n.deletedFriends),
          backgroundColor: AppColors.primary(context),
        ),
      );
    }
  }
}
