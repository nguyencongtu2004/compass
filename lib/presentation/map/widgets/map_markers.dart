import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:minecraft_compass/utils/format_utils.dart';

import '../../../models/user_model.dart';
import '../../../models/newsfeed_post_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/common_avatar.dart';
import '../../profile/bloc/profile_bloc.dart';
import 'map_toggle_switch.dart';

class MapMarkersBuilder {
  static List<Marker> buildMarkers({
    required BuildContext context,
    required LatLng? currentLocation,
    required List<UserModel> friends,
    required List<NewsfeedPost> feedPosts,
    required MapDisplayMode currentMode,
  }) {
    final markers = <Marker>[];

    // Marker cho người dùng hiện tại (luôn hiển thị)
    if (currentLocation != null) {
      markers.add(
        Marker(
          point: currentLocation,
          width: 50,
          height: 50,
          rotate: true,
          alignment: Alignment.center,
          child: _CurrentUserMarker(),
        ),
      );
    } 
    
    // Hiển thị markers dựa trên chế độ hiện tại
    switch (currentMode) {
      case MapDisplayMode.locations:
        // Marker cho bạn bè
        for (final friend in friends) {
          final friendLocation = LatLng(
            friend.currentLocation!.latitude,
            friend.currentLocation!.longitude,
          );
          markers.add(
            Marker(
              point: friendLocation,
              width: 200,
              height: 90,
              rotate: true,
              alignment: Alignment.center,
              child: _FriendMarker(friend: friend),
            ),
          );
        }
        break;
      case MapDisplayMode.friends:
      case MapDisplayMode.explore:
        // Marker cho feed posts
        for (final post in feedPosts) {
          final postLocation = LatLng(
            post.location!.latitude,
            post.location!.longitude,
          );
          markers.add(
            Marker(
              point: postLocation,
              width: 200,
              height: 160,
              rotate: true,
              alignment: Alignment.center,
              child: _FeedMarker(post: post),
            ),
          );
        }
        break;
    }

    return markers;
  }
}

class _CurrentUserMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) => profileState is ProfileLoaded
          ? CommonAvatar(
              radius: 25,
              avatarUrl: profileState.user.avatarUrl,
              displayName: profileState.user.displayName,
              borderSpacing: 0,
              borderColor: AppColors.primary(context),
            )
          : const CommonAvatar(radius: 25),
    );
  }
}

class _FriendMarker extends StatelessWidget {
  final UserModel friend;

  const _FriendMarker({required this.friend});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar bạn bè
        CommonAvatar(
          radius: 25,
          avatarUrl: friend.avatarUrl,
          displayName: friend.displayName,
          borderSpacing: 0,
          borderColor: AppColors.secondary(context),
        ),
        const SizedBox(height: AppSpacing.xs),

        // Tên bạn bè
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.outline(context).withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            friend.displayName,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurface(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _FeedMarker extends StatelessWidget {
  final NewsfeedPost post;

  const _FeedMarker({required this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Hình ảnh feed post
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary(context), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.onSurface(context).withValues(alpha: 0.2),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: post.imageUrl.isNotEmpty ? post.imageUrl : '',
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.surfaceVariant(context),
                child: Icon(
                  Icons.image,
                  color: AppColors.onSurfaceVariant(context),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.surfaceVariant(context),
                child: Icon(
                  Icons.broken_image,
                  color: AppColors.onSurfaceVariant(context),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),

        // Thông tin người đăng
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.outline(context).withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.onSurface(context).withValues(alpha: 0.1),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar người đăng
              CommonAvatar(
                radius: 12,
                avatarUrl: post.userAvatarUrl,
                displayName: post.userDisplayName,
              ),
              const SizedBox(width: AppSpacing.xs),

              // Caption người đăng
              post.caption == null || post.caption!.isEmpty
                  ? const SizedBox.shrink()
                  : Text(
                      post.caption!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurface(context),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

              // // Tên người đăng
              // Text(
              //   post.userDisplayName,
              //   style: AppTextStyles.bodySmall.copyWith(
              //     color: AppColors.onSurface(context),
              //     fontWeight: FontWeight.w500,
              //   ),
              //   maxLines: 1,
              //   overflow: TextOverflow.ellipsis,
              // ),

              // // Khoảng cách giữa tên và thời gian
              Text(
                ' • ',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurface(context).withValues(alpha: 0.6),
                ),
              ),

              // Thời gian đăng
              Text(
                FormatUtils.getShortTimeAgo(post.createdAt),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurface(context).withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
