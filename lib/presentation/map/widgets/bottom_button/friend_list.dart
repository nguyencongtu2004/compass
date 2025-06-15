import 'package:minecraft_compass/config/l10n/localization_extensions.dart';
import 'package:flutter/material.dart';
import 'package:minecraft_compass/models/user_model.dart';
import 'package:minecraft_compass/presentation/core/theme/app_colors.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';
import 'package:minecraft_compass/presentation/core/theme/app_text_styles.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_avatar.dart';

class FriendList extends StatefulWidget {
  final List<UserModel> friends;
  final void Function(UserModel)? onFriendSelected;

  const FriendList({
    super.key,
    required this.friends,
    required this.onFriendSelected,
  });

  @override
  State<FriendList> createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
  UserModel? _selectedFriend;

  void _onSelectFriend(UserModel friend) {
    setState(() => _selectedFriend = friend);
    // Gọi callback nếu có
    widget.onFriendSelected?.call(friend);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.friends.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant(context),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.people_outline,
                size: 32,
                color: AppColors.onSurfaceVariant(context),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.l10n.noFriendsYet,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: widget.friends.length,
        itemBuilder: (context, index) {
          final friend = widget.friends[index];
          final isSelected = _selectedFriend?.uid == friend.uid;

          return GestureDetector(
            onTap: () => _onSelectFriend(friend),
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: AppSpacing.md),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar sử dụng CommonAvatar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary(
                                  context,
                                ).withValues(alpha: 0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: CommonAvatar(
                      radius: 35,
                      avatarUrl: friend.avatarUrl,
                      displayName: friend.displayName,
                      backgroundColor: AppColors.primary(context),
                      textColor: AppColors.onPrimary(context),
                      borderColor: isSelected
                          ? AppColors.primary(context)
                          : AppColors.outline(context).withValues(alpha: 0.3),
                      borderSpacing: isSelected ? 3 : 1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs2),

                  // Tên hiển thị
                  Text(
                    friend.displayName,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary(context)
                          : AppColors.onSurface(context),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
