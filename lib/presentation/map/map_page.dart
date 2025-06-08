import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:minecraft_compass/presentation/compass/bloc/compass_bloc.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_avatar.dart';
import 'package:minecraft_compass/presentation/profile/bloc/profile_bloc.dart';
import 'package:minecraft_compass/presentation/friend/bloc/friend_bloc.dart';
import 'package:minecraft_compass/models/user_model.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.onBackPressed});
  final Function onBackPressed;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  late final AnimatedMapController _mapController;
  LatLng? _currentLocation;
  final LatLng _defaultLocation = const LatLng(21.0285, 105.8542); // Hà Nội
  List<UserModel> _friends = [];

  @override
  void initState() {
    super.initState();
    _mapController = AnimatedMapController(vsync: this);
    _initializeLocation();
    _loadFriends();
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
    }
  }

  // Xử lý khi ấn nút fit bounds
  void _onFitBoundsPressed() {
    if (_currentLocation != null) {
      final allPoints = [
        _currentLocation!,
        ..._friends.map(
          (friend) => LatLng(
            friend.currentLocation!.latitude,
            friend.currentLocation!.longitude,
          ),
        ),
      ];
      _fitBounds(allPoints);
    }
  }

  // Xử lý khi ấn nút my location
  void _onMyLocationPressed() {
    if (_currentLocation != null) {
      // Di chuyển đến vị trí hiện tại với animation mượt
      _mapController.animateTo(dest: _currentLocation!, zoom: 16.0);
    } else {
      // Yêu cầu lấy vị trí hiện tại
      context.read<CompassBloc>().add(const RefreshCurrentLocation());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CompassBloc, CompassState>(
          listener: (context, state) {
            if (state is CompassReady &&
                state.currentLat != null &&
                state.currentLng != null) {
              final newLocation = LatLng(state.currentLat!, state.currentLng!);

              setState(() {
                _currentLocation = newLocation;
              });
            }
          },
        ),
        BlocListener<FriendBloc, FriendState>(
          listener: (context, state) {
            if (state is FriendAndRequestsLoadSuccess) {
              setState(() {
                _friends = state.friends
                    .where(
                      (friend) =>
                          friend.currentLocation?.latitude != null &&
                          friend.currentLocation?.longitude != null,
                    )
                    .toList();
              });
            }
          },
        ),
      ],
      child: Stack(
        children: [
          // Map widget
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController.mapController,
              options: MapOptions(
                initialCenter: _currentLocation ?? _defaultLocation,
                initialZoom: 15.0,
                minZoom: 5.0,
                maxZoom: 30.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
                keepAlive: true,
              ),
              children: [
                // Tile layer - thay đổi theo theme
                _buildTileLayer(),

                // Marker layer hiển thị avatar người dùng và bạn bè
                MarkerLayer(markers: _buildMarkers()),

                // Floating action buttons
                _buildFloatingActionButtons(),
              ],
            ),
          ),

          // Nút quay lại
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface(context),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.onSurface(context).withValues(alpha: 0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_upward, size: 30),
                onPressed: () => widget.onBackPressed(),
                color: AppColors.onSurface(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tạo tile layer với theme support
  Widget _buildTileLayer() {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.nctu.minecraft_compass',
      maxZoom: 19,
      minZoom: 5,
      tileBuilder: Theme.of(context).brightness == Brightness.dark
          ? (context, tileWidget, tile) {
              return ColorFiltered(
                colorFilter: const ColorFilter.matrix(<double>[
                  // Đảo màu
                  -1, 0, 0, 0, 255,
                  0, -1, 0, 0, 255,
                  0, 0, -1, 0, 255,
                  0, 0, 0, 1, 0,
                ]),
                child: tileWidget,
              );
            }
          : null,
    );
  }

  // Tạo danh sách markers
  List<Marker> _buildMarkers() {
    final markers = <Marker>[]; // Marker cho người dùng hiện tại
    if (_currentLocation != null) {
      markers.add(
        Marker(
          point: _currentLocation!,
          width: 50,
          height: 50,
          rotate: true,
          alignment: Alignment.center,
          child: _buildCurrentUserMarker(),
        ),
      );
    }

    // Marker cho bạn bè
    for (final friend in _friends) {
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
          child: _buildFriendMarker(friend),
        ),
      );
    }

    return markers;
  }

  // Tạo marker cho người dùng hiện tại
  Widget _buildCurrentUserMarker() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) => profileState is ProfileLoaded
          ? CommonAvatar(
              radius: 50,
              avatarUrl: profileState.user.avatarUrl,
              displayName: profileState.user.displayName,
              borderSpacing: 0,
              borderColor: AppColors.primary(context),
            )
          : const CommonAvatar(radius: 25),
    );
  }

  // Tạo marker cho bạn bè
  Widget _buildFriendMarker(UserModel friend) {
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
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Tạo floating action buttons
  Widget _buildFloatingActionButtons() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Button zoom to fit all markers
          if (_friends.isNotEmpty)
            FloatingActionButton(
              mini: true,
              heroTag: "fit_bounds",
              backgroundColor: AppColors.secondary(context),
              foregroundColor: AppColors.onSecondary(context),
              elevation: 6,
              onPressed: _onFitBoundsPressed,
              child: const Icon(Icons.fit_screen, size: 20),
            ),

          if (_friends.isNotEmpty) const SizedBox(height: 12),

          // Button về vị trí hiện tại
          FloatingActionButton(
            mini: true,
            heroTag: "my_location",
            backgroundColor: AppColors.primary(context),
            foregroundColor: AppColors.onPrimary(context),
            elevation: 6,
            onPressed: _onMyLocationPressed,
            child: const Icon(Icons.my_location, size: 20),
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
