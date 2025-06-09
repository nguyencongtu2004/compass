import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:minecraft_compass/presentation/compass/bloc/compass_bloc.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';
import 'package:minecraft_compass/presentation/map/widgets/map_back_button.dart';
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
  bool _showFriends = true; // true: hiển thị bạn bè, false: hiển thị feeds

  @override
  void initState() {
    super.initState();
    _mapController = AnimatedMapController(vsync: this);
    _initializeLocation();
    _loadDefaultLocation();
    _loadFriends();
    _loadFeedPosts();
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

  // Xử lý khi ấn nút fit bounds
  void _onFitBoundsPressed() {
    final allPoints = <LatLng>[];

    // Thêm vị trí hiện tại
    if (_currentLocation != null) {
      allPoints.add(_currentLocation!);
    }

    // Thêm vị trí dựa trên chế độ hiện tại
    if (_showFriends) {
      // Thêm vị trí bạn bè
      allPoints.addAll(
        _friends.map(
          (friend) => LatLng(
            friend.currentLocation!.latitude,
            friend.currentLocation!.longitude,
          ),
        ),
      );
    } else {
      // Thêm vị trí feed posts
      allPoints.addAll(
        _feedPosts.map(
          (post) => LatLng(post.location!.latitude, post.location!.longitude),
        ),
      );
    }

    if (allPoints.isNotEmpty) {
      _fitBounds(allPoints);
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

  @override
  Widget build(BuildContext context) {
    return MapBlocListeners(
      onLocationChanged: (location) {
        final bool isFirstLocation = _currentLocation == null;
        setState(() => _currentLocation = location);

        // Tự động di chuyển camera đến vị trí hiện tại khi lần đầu lấy được vị trí
        if (isFirstLocation && location != null) {
          Future.delayed(const Duration(milliseconds: 300), () {
            _mapController.animateTo(dest: location, zoom: 16.0);
          });
        }
      },
      onFriendsChanged: (friends) {
        setState(() => _friends = friends);
      },
      onFeedPostsChanged: (feedPosts) {
        setState(() => _feedPosts = feedPosts);
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
            showFriends: _showFriends,
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
                showFriends: _showFriends,
                onToggleToFriends: () {
                  if (!_showFriends) {
                    setState(() => _showFriends = true);
                  }
                },
                onToggleToFeeds: () {
                  if (_showFriends) {
                    setState(() => _showFriends = false);
                    _loadFeedPosts();
                  }
                },
              ),
            ),
          ),

          // Floating action buttons
          MapFloatingActionButtons(
            showFitBoundsButton:
                (_showFriends && _friends.isNotEmpty) ||
                (!_showFriends && _feedPosts.isNotEmpty),
            onFitBoundsPressed: _onFitBoundsPressed,
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
    super.dispose();
  }
}
