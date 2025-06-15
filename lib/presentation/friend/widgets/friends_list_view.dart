import 'package:minecraft_compass/config/l10n/localization_extensions.dart';
import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../bloc/friend_bloc.dart';
import 'friend_tile.dart';
import 'friend_request_tile.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

class FriendsListView extends StatelessWidget {
  final FriendAndRequestsLoadSuccess state;
  final Function(UserModel) onRemoveFriend;
  final Function(String) onAcceptRequest;
  final Function(String) onDeclineRequest;
  final VoidCallback onRefresh;

  const FriendsListView({
    super.key,
    required this.state,
    required this.onRemoveFriend,
    required this.onAcceptRequest,
    required this.onDeclineRequest,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: CustomScrollView(
        slivers: [
          // Friend requests section
          if (state.friendRequests.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Text(
                  context.l10n.friendRequestLength(state.friendRequests.length),
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.onSurface(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final request = state.friendRequests[index];
                return FriendRequestTile(
                  requester: request,
                  onAccept: () => onAcceptRequest(request.uid),
                  onDecline: () => onDeclineRequest(request.uid),
                );
              }, childCount: state.friendRequests.length),
            ),
            const SliverToBoxAdapter(child: Divider(height: 1)),
          ], // Friends section header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Text(
                state.friends.isEmpty
                    ? context.l10n.noFriendsYet
                    : context.l10n.friendsLength(state.friends.length),
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.onSurface(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Friends list
          if (state.friends.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  context.l10n.noFriendsYetNaddFriendsByEmail,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.onSurfaceVariant(context),
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final friend = state.friends[index];
                return FriendTile(
                  friend: friend,
                  onRemove: () => onRemoveFriend(friend),
                );
              }, childCount: state.friends.length),
            ),
        ],
      ),
    );
  }
}
