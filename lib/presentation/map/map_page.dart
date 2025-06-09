import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:minecraft_compass/presentation/compass/bloc/compass_bloc.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';
import 'package:minecraft_compass/presentation/map/widgets/map_bloc_listeners.dart';
import 'package:minecraft_compass/presentation/map/widgets/map_create_post_button.dart';
import 'package:minecraft_compass/presentation/map/widgets/map_floating_action_buttons.dart';
import 'package:minecraft_compass/presentation/map/widgets/map_toggle_switch.dart';
import 'package:minecraft_compass/presentation/map/widgets/map_widget.dart';
import 'package:minecraft_compass/presentation/friend/bloc/friend_bloc.dart';
import 'package:minecraft_compass/presentation/newfeed/bloc/newsfeed_bloc.dart';
import 'package:minecraft_compass/presentation/auth/bloc/auth_bloc.dart';
import 'package:minecraft_compass/models/user_model.dart';
import 'package:minecraft_compass/models/newsfeed_post_model.dart';
import 'package:minecraft_compass/data/services/shared_preferences_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.onBackPressed});
  final Function onBackPressed;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  late final AnimatedMapController _mapController;
  LatLng? _currentLocation;
  late LatLng _defaultLocation;
  List<UserModel> _friends = [];
  List<NewsfeedPost> _feedPosts = [];
  MapDisplayMode _currentMode =
      MapDisplayMode.locations; // Chế độ hiển thị hiện tại
  bool _firstTimeLoadExplore =
      true; // Biến để kiểm tra lần đầu vào chế độ Explore

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _mapController = AnimatedMapController(vsync: this);
    _initializeLocation();
    _loadDefaultLocation();
    _loadFriends();
    _loadFeedPosts();
  }

  // Callback khi người dùng thay đổi vị trí map (cho chế độ explore)
  void _onMapPositionChanged(LatLng center, double zoom) {
    if (_currentMode == MapDisplayMode.explore && _currentLocation != null) {
      // Debounce để tránh quá nhiều requests
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
        // Tính bán kính dựa trên zoom level thực tế từ map
        final radius = _calculateRadiusFromZoom(customZoom: zoom);

        // Lấy danh sách friend UIDs để loại trừ + current user ID
        List<String>? excludeFriendUids;
        String? currentUserId;

        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          currentUserId = authState.user.uid;
        }

        final friendState = context.read<FriendBloc>().state;
        if (friendState is FriendAndRequestsLoadSuccess) {
          excludeFriendUids = friendState.friends
              .map((friend) => friend.uid)
              .toList();
        }

        context.read<NewsfeedBloc>().add(
          LoadPostsByLocation(
            currentLat: center.latitude,
            currentLng: center.longitude,
            radiusInMeters: radius,
            excludeFriendUids: excludeFriendUids,
            currentUserId: currentUserId,
          ),
        );
      });
    }
  }

  void _loadFeedPosts() {
    final newsfeedState = context.read<NewsfeedBloc>().state;
    if (newsfeedState is PostsLoaded) {
      setState(() {
        _feedPosts = newsfeedState.posts
            .where((post) => post.location != null)
            .toList();
      });
    } else {
      // Load posts if not already loaded
      context.read<NewsfeedBloc>().add(const LoadPosts());
    }
  }

  // Tính bán kính từ zoom level thực tế của map
  double _calculateRadiusFromZoom({double? customZoom}) {
    // Lấy zoom level thực tế từ map controller hoặc sử dụng giá trị được truyền vào
    final double currentZoom =
        customZoom ?? _mapController.mapController.camera.zoom;

    // Tính toán bán kính dựa trên zoom level thực tế
    // Công thức: bán kính tỉ lệ nghịch với zoom level
    // Zoom level càng cao (zoom in) thì bán kính càng nhỏ
    const double baseRadius = 1000; // 1000m tại zoom level 15
    const double baseZoom = 15.0;

    // Tính bán kính theo công thức exponential
    final double radius = baseRadius * math.pow(2, baseZoom - currentZoom);

    // Đối với explore mode, sử dụng bán kính lớn hơn để tìm nhiều posts hơn
    if (_currentMode == MapDisplayMode.explore) {
      // Gấp đôi bán kính cho explore mode
      final double exploreRadius = radius * 2;
      // Tối thiểu 2km cho explore mode
      return exploreRadius.clamp(2000, 1650000);
    }

    // Giới hạn từ 100m đến 1650km cho friends/feeds mode
    return radius.clamp(100, 1650000);
  }

  // Lấy danh sách friend UIDs
  List<String> _getFriendUids() {
    final friendState = context.read<FriendBloc>().state;
    if (friendState is FriendAndRequestsLoadSuccess) {
      return friendState.friends.map((friend) => friend.uid).toList();
    }
    return [];
  } // Xử lý chuyển đổi sang chế độ Friends

  void _onToggleToFriends() {
    if (_currentMode != MapDisplayMode.locations) {
      setState(() => _currentMode = MapDisplayMode.locations);
      _loadFriends();
      // Load posts từ bạn bè nếu cần
      final friendUids = _getFriendUids();
      if (friendUids.isNotEmpty) {
        context.read<NewsfeedBloc>().add(
          LoadPostsFromFriends(friendUids: friendUids),
        );
      }
    } else {
      // Nếu đã ở chế độ Friends, chỉ cần auto fit bounds
      _autoFitBoundsAfterDataLoad();
    }
  }

  // Xử lý chuyển đổi sang chế độ Feeds
  void _onToggleToFeeds() {
    if (_currentMode != MapDisplayMode.friends) {
      setState(() => _currentMode = MapDisplayMode.friends);

      // Load posts từ mình và bạn bè
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        final currentUserId = authState.user.uid;
        final friendUids = _getFriendUids();

        context.read<NewsfeedBloc>().add(
          LoadFeedPosts(currentUserId: currentUserId, friendUids: friendUids),
        );
      }
    } else {
      // Nếu đã ở chế độ Feeds, chỉ cần auto fit bounds
      _autoFitBoundsAfterDataLoad();
    }
  }

  // Xử lý chuyển đổi sang chế độ Explore
  void _onToggleToExplore() {
    if (_currentMode != MapDisplayMode.explore) {
      setState(() => _currentMode = MapDisplayMode.explore);
      _loadPostsByLocation();
    } else {
      // Nếu đã ở chế độ Explore, chỉ cần auto fit bounds
      _autoFitBoundsAfterDataLoad();
    }
  }

  // Auto fit bounds sau khi load thành công data hoặc đổi chế độ
  void _autoFitBoundsAfterDataLoad() {
    // Delay một chút để đảm bảo data đã được update
    final allPoints = <LatLng>[];

    // Thêm vị trí hiện tại
    if (_currentLocation != null) {
      allPoints.add(_currentLocation!);
    }

    // Thêm vị trí dựa trên chế độ hiện tại
    switch (_currentMode) {
      case MapDisplayMode.locations:
        // Thêm vị trí bạn bè (chỉ khi có bạn bè)
        if (_friends.isNotEmpty) {
          allPoints.addAll(
            _friends
                .where((friend) => friend.currentLocation != null)
                .map(
                  (friend) => LatLng(
                    friend.currentLocation!.latitude,
                    friend.currentLocation!.longitude,
                  ),
                ),
          );
        }
        break;
      case MapDisplayMode.friends:
      case MapDisplayMode.explore:
        // Thêm vị trí feed posts (chỉ khi có posts)
        if (_feedPosts.isNotEmpty) {
          allPoints.addAll(
            _feedPosts
                .where((post) => post.location != null)
                .map(
                  (post) =>
                      LatLng(post.location!.latitude, post.location!.longitude),
                ),
          );
        }
        break;
    }

    // Chỉ fit bounds khi có ít nhất 2 điểm (để có bounds hợp lý)
    if (allPoints.length >= 2) {
      _fitBounds(allPoints);
    }
  }

  // Load posts theo vị trí hiện tại
  void _loadPostsByLocation() {
    if (_currentLocation != null) {
      // Tính bán kính dựa trên zoom level thực tế từ map controller
      final radius = _calculateRadiusFromZoom();

      // Nếu ở chế độ explore, lấy danh sách friend UIDs để loại trừ + current user ID
      List<String>? excludeFriendUids;
      String? currentUserId;

      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        currentUserId = authState.user.uid;
      }

      if (_currentMode == MapDisplayMode.explore) {
        final friendState = context.read<FriendBloc>().state;
        if (friendState is FriendAndRequestsLoadSuccess) {
          excludeFriendUids = friendState.friends
              .map((friend) => friend.uid)
              .toList();
        }
      }

      context.read<NewsfeedBloc>().add(
        LoadPostsByLocation(
          currentLat: _currentLocation!.latitude,
          currentLng: _currentLocation!.longitude,
          radiusInMeters: radius,
          excludeFriendUids: excludeFriendUids,
          currentUserId: currentUserId,
        ),
      );
    }
  }

  Future<void> _loadDefaultLocation() async {
    try {
      final cachedLocation = await SharedPreferencesService.getCachedLocation();
      if (cachedLocation != null) {
        setState(() {
          _defaultLocation = LatLng(
            cachedLocation['latitude']!,
            cachedLocation['longitude']!,
          );
        });
      } else {
        // Fallback to Hanoi coordinates if no cached location
        setState(() {
          _defaultLocation = const LatLng(21.0285, 105.8542);
        });
      }
    } catch (e) {
      // Fallback to Hanoi coordinates on error
      setState(() {
        _defaultLocation = const LatLng(21.0285, 105.8542);
      });
    }
  }

  void _loadFriends() {
    final friendState = context.read<FriendBloc>().state;
    if (friendState is FriendAndRequestsLoadSuccess) {
      setState(() {
        _friends = friendState.friends
            .where(
              (friend) =>
                  friend.currentLocation?.latitude != null &&
                  friend.currentLocation?.longitude != null,
            )
            .toList();
      });
    }
  }

  void _initializeLocation() {
    final compassState = context.read<CompassBloc>().state;
    if (compassState is CompassReady &&
        compassState.currentLat != null &&
        compassState.currentLng != null) {
      setState(() {
        _currentLocation = LatLng(
          compassState.currentLat!,
          compassState.currentLng!,
        );
      });
    } else {
      // Yêu cầu lấy vị trí hiện tại nếu chưa có hoặc state không phải CompassReady
      context.read<CompassBloc>().add(const RefreshCurrentLocation());

      // Nếu có thông tin user, cũng trigger GetCurrentLocationAndUpdate để đảm bảo
      final authState = context.read<AuthBloc>();
      if (authState.state is AuthAuthenticated) {
        final user = (authState.state as AuthAuthenticated).user;
        context.read<CompassBloc>().add(
          GetCurrentLocationAndUpdate(uid: user.uid),
        );
      }
    }
  }

  // Xử lý khi ấn nút my location
  void _onMyLocationPressed() {
    if (_currentLocation != null) {
      // Di chuyển đến vị trí hiện tại với animation mượt
      _mapController.animateTo(dest: _currentLocation!, zoom: 16.0);
    } else {
      // Yêu cầu lấy vị trí hiện tại và sẽ tự động di chuyển camera khi có vị trí
      context.read<CompassBloc>().add(const RefreshCurrentLocation());

      // Nếu có thông tin user, cũng trigger GetCurrentLocationAndUpdate
      final authState = context.read<AuthBloc>();
      if (authState.state is AuthAuthenticated) {
        final user = (authState.state as AuthAuthenticated).user;
        context.read<CompassBloc>().add(
          GetCurrentLocationAndUpdate(uid: user.uid),
        );
      }
    }
  }

  // Xử lý khi ấn nút reset rotation - xoay bản đồ về hướng Bắc
  void _onResetRotationPressed() {
    // Reset rotation về 0 (hướng Bắc) với animation
    _mapController.animatedRotateReset();
  }

  @override
  Widget build(BuildContext context) {
    return MapBlocListeners(
      onLocationChanged: (location) {
        final bool isFirstLocation = _currentLocation == null;
        setState(() => _currentLocation = location);

        // Tự động di chuyển camera đến vị trí hiện tại khi lần đầu lấy được vị trí
        if (isFirstLocation && location != null) {
          Future.delayed(const Duration(milliseconds: 300), () {
            _autoFitBoundsAfterDataLoad();
          });
        }
      },
      onFriendsChanged: (friends) {
        setState(() => _friends = friends);
        // Auto fit bounds sau khi load thành công friends
        _autoFitBoundsAfterDataLoad();
      },
      onFeedPostsChanged: (feedPosts) {
        setState(() => _feedPosts = feedPosts);
        switch (_currentMode) {
          case MapDisplayMode.locations:
          case MapDisplayMode.friends:
            // Khi ở chế độ locations hoặc friends, chỉ cần fit bounds nếu có friends
            if (_friends.isNotEmpty) {
              _autoFitBoundsAfterDataLoad();
            }
            break;
          case MapDisplayMode.explore:
            // Khi ở chế độ explore, fit bounds với feed posts
            if (_feedPosts.isNotEmpty && _firstTimeLoadExplore) {
              _firstTimeLoadExplore = false; // Chỉ fit bounds lần đầu
              _autoFitBoundsAfterDataLoad();
            }
            break;
        }
      },
      child: Stack(
        children: [
          // Map widget
          MapWidget(
            mapController: _mapController,
            currentLocation: _currentLocation ?? _defaultLocation,
            defaultLocation: _defaultLocation,
            friends: _friends,
            feedPosts: _feedPosts,
            currentMode: _currentMode,
            onMapPositionChanged: _onMapPositionChanged,
          ),

          // Nút quay lại
          // MapBackButton(onPressed: () => widget.onBackPressed()),

          // Toggle switch ở giữa top
          Positioned(
            top: AppSpacing.md,
            left: 0,
            right: 0,
            child: Center(
              child: MapToggleSwitch(
                currentMode: _currentMode,
                onToggleToLocations: _onToggleToFriends,
                onToggleToFriends: _onToggleToFeeds,
                onToggleToExplore: _onToggleToExplore,
              ),
            ),
          ),
          // Floating action buttons
          MapFloatingActionButtons(
            onResetRotationPressed: _onResetRotationPressed,
            onMyLocationPressed: _onMyLocationPressed,
          ),

          // Create post button
          Positioned(
            bottom: AppSpacing.md,
            left: 0,
            right: 0,
            child: const MapCreatePostButton(),
          ),
        ],
      ),
    );
  }

  // Helper method để fit camera vào bounds của các điểm
  void _fitBounds(List<LatLng> points) {
    if (points.isEmpty) return;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    final bounds = LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));

    // Sử dụng animatedFitCamera với animation mượt mà và giới hạn zoom tối đa
    _mapController.animatedFitCamera(
      cameraFit: CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(80),
        maxZoom: 15.0,
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }
}
