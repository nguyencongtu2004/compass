import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minecraft_compass/presentation/compass/bloc/compass_bloc.dart';
import 'package:minecraft_compass/presentation/newfeed/bloc/newsfeed_bloc.dart';
import '../presentation/profile/bloc/profile_bloc.dart';
import '../presentation/friend/bloc/friend_bloc.dart';
import '../presentation/map/bloc/map_bloc.dart';

/// Service để xử lý logic khởi tạo dữ liệu sau khi đăng nhập
class AppInitialization {
  /// Khởi tạo dữ liệu cần thiết sau khi người dùng đăng nhập
  static void initializeUserData(BuildContext context, User user) {
    // Load profile data
    context.read<ProfileBloc>().add(const ProfileLoadRequested());

    // Load friends and friend requests
    context.read<FriendBloc>().add(LoadFriendsAndRequests(user.uid));

    // Load newsfeed posts
    context.read<NewsfeedBloc>().add(const LoadPosts()); // Load compass data
    context.read<CompassBloc>().add(
      GetCurrentLocationAndUpdate(uid: user.uid),
    );

    // Initialize map data
    context.read<MapBloc>().add(const MapInitialized());
  }

  /// Reset dữ liệu khi người dùng đăng xuất
  static void resetUserData(BuildContext context) {
    // Reset profile data
    context.read<ProfileBloc>().add(const ProfileResetRequested());

    // Reset friend data
    context.read<FriendBloc>().add(
      const FriendResetRequested(),
    ); // Reset newsfeed data
    context.read<NewsfeedBloc>().add(const NewsfeedResetRequested());

    // Reset map data
    context.read<MapBloc>().add(const MapResetRequested());
  }

  /// Kiểm tra xem dữ liệu đã được khởi tạo hoàn tất chưa
  static bool isDataInitializationComplete(BuildContext context) {
    final profileState = context.read<ProfileBloc>().state;
    final friendState = context.read<FriendBloc>().state;
    final newsfeedState = context.read<NewsfeedBloc>().state;
    final mapState = context.read<MapBloc>().state;

    final profileLoaded =
        profileState is ProfileLoaded || profileState is ProfileError;
    final friendLoaded =
        friendState is FriendAndRequestsLoadSuccess ||
        friendState is FriendOperationFailure;

    final newsfeedLoaded =
        newsfeedState is PostsLoaded || newsfeedState is NewsfeedError;

    final mapLoaded = mapState is MapReady || mapState is MapError;

    return profileLoaded && friendLoaded && newsfeedLoaded && mapLoaded;
  }
}
