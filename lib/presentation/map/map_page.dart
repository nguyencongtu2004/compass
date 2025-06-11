import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:minecraft_compass/models/user_model.dart';

import '../compass/bloc/compass_bloc.dart';
import 'bloc/map_bloc.dart';
import 'widgets/bottom_button/map_bottom_action_widget.dart';
import 'widgets/bottom_button/map_floating_action_buttons.dart';
import 'widgets/map_toggle_switch.dart';
import 'widgets/map_widget.dart';

class MapPage extends StatefulWidget {
  const MapPage({
    super.key,
    required this.onBackPressed,
    this.paddingTop = 0.0,
  });

  final Function onBackPressed;
  final double paddingTop;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  late final AnimatedMapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = AnimatedMapController(vsync: this);

    // Khởi tạo MapBloc
    context.read<MapBloc>().add(const MapInitialized());

    // Lắng nghe vị trí từ CompassBloc
    _initializeLocationListener();
  }

  void _initializeLocationListener() {
    // Lấy vị trí hiện tại từ CompassBloc
    final compassState = context.read<CompassBloc>().state;
    if (compassState is CompassReady &&
        compassState.currentLat != null &&
        compassState.currentLng != null) {
      context.read<MapBloc>().add(
        MapLocationUpdated(
          LatLng(compassState.currentLat!, compassState.currentLng!),
        ),
      );
    } else {
      // Yêu cầu lấy vị trí hiện tại
      context.read<CompassBloc>().add(const RefreshCurrentLocation());
    }
  }

  // Xử lý chuyển đổi sang chế độ Locations (xem vị trí bạn bè và mình)
  void _onToggleToLocations() {
    context.read<MapBloc>().add(const MapModeChanged(MapDisplayMode.locations));
  }

  // Xử lý chuyển đổi sang chế độ Friends (xem bài viết bạn bè và mình)
  void _onToggleToFriends() {
    context.read<MapBloc>().add(const MapModeChanged(MapDisplayMode.friends));
  }

  // Xử lý chuyển đổi sang chế độ Explore (xem bài viết người lạ và mình)
  void _onToggleToExplore() {
    context.read<MapBloc>().add(const MapModeChanged(MapDisplayMode.explore));
  }

  // Xử lý khi map position thay đổi
  void _onMapPositionChanged(LatLng center, double zoom) {
    context.read<MapBloc>().add(MapPositionChanged(center: center, zoom: zoom));
  }

  // Xử lý khi ấn nút my location
  void _onMyLocationPressed() {
    final mapState = context.read<MapBloc>().state;
    if (mapState is MapReady && mapState.currentLocation != null) {
      // Di chuyển đến vị trí hiện tại với animation mượt
      _mapController.animateTo(dest: mapState.currentLocation!, zoom: 16.0);
    } else {
      // Yêu cầu lấy vị trí hiện tại
      context.read<CompassBloc>().add(const RefreshCurrentLocation());
    }
  }

  // Xử lý khi ấn nút reset rotation - xoay bản đồ về hướng Bắc
  void _onResetRotationPressed() {
    // Reset rotation về 0 (hướng Bắc) với animation
    _mapController.animatedRotateReset();
  }

  void _onFriendTap(UserModel friend) {
    if (friend.currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${friend.displayName} chưa có thông tin vị trí'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      );
      return;
    }
    // Animation đến vị trí của bạn bè
    _mapController.animateTo(
      dest: LatLng(
        friend.currentLocation!.latitude,
        friend.currentLocation!.longitude,
      ),
      zoom: 16.0,
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
      minLat = minLat > point.latitude ? point.latitude : minLat;
      maxLat = maxLat < point.latitude ? point.latitude : maxLat;
      minLng = minLng > point.longitude ? point.longitude : minLng;
      maxLng = maxLng < point.longitude ? point.longitude : maxLng;
    }

    final bounds = LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));

    // Sử dụng animatedFitCamera với animation mượt mà và giới hạn zoom tối đa
    _mapController.animatedFitCamera(
      cameraFit: CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50.0),
        maxZoom: 16.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Lắng nghe CompassBloc để cập nhật vị trí
        BlocListener<CompassBloc, CompassState>(
          listener: (context, state) {
            if (state is CompassReady &&
                state.currentLat != null &&
                state.currentLng != null) {
              final newLocation = LatLng(state.currentLat!, state.currentLng!);
              context.read<MapBloc>().add(MapLocationUpdated(newLocation));
            }
          },
        ),
        // Lắng nghe MapBloc để xử lý auto fit bounds
        BlocListener<MapBloc, MapState>(
          listener: (context, state) {
            if (state is MapReady && state.shouldAutoFitBounds) {
              final points = state.getPointsForCurrentMode();
              if (points.length >= 2) {
                Future.delayed(const Duration(milliseconds: 300), () {
                  _fitBounds(points);
                });
              }
            }
          },
        ),
      ],
      child: BlocBuilder<MapBloc, MapState>(
        builder: (context, mapState) {
          if (mapState is MapLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (mapState is MapError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Lỗi: ${mapState.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<MapBloc>().add(const MapInitialized());
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (mapState is! MapReady) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              // Map widget
              MapWidget(
                mapController: _mapController,
                currentLocation:
                    mapState.currentLocation ?? mapState.defaultLocation,
                defaultLocation: mapState.defaultLocation,
                friends: mapState.friends,
                feedPosts: mapState.feedPosts,
                currentMode: mapState.currentMode,
                onMapPositionChanged: _onMapPositionChanged,
              ),

              // Toggle switch ở giữa top
              Positioned(
                top: widget.paddingTop,
                left: 0,
                right: 0,
                child: Center(
                  child: MapToggleSwitch(
                    currentMode: mapState.currentMode,
                    onToggleToLocations: _onToggleToLocations,
                    onToggleToFriends: _onToggleToFriends,
                    onToggleToExplore: _onToggleToExplore,
                  ),
                ),
              ),

              // Floating action buttons
              MapFloatingActionButtons(
                onResetRotationPressed: _onResetRotationPressed,
                onMyLocationPressed: _onMyLocationPressed,
                isBottomWidgetExpanded:
                    mapState.currentMode == MapDisplayMode.locations,
              ),

              // Bottom action widget (Create post button or Friends list)
              MapBottomActionWidget(onFriendTap: _onFriendTap),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
