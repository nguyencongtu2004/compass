import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:minecraft_compass/models/marker_cluster.dart';
import 'package:minecraft_compass/models/newsfeed_post_model.dart';
import 'package:minecraft_compass/models/user_model.dart';

import 'marker/map_markers.dart';
import 'map_toggle_switch.dart';
import 'post_detail/modern_post_overlay.dart';

class MapWidget extends StatefulWidget {
  final AnimatedMapController mapController;
  final LatLng? currentLocation;
  final LatLng defaultLocation;
  final List<UserModel> friends;
  final List<NewsfeedPost> feedPosts;
  final MapDisplayMode currentMode;
  final double initialZoom;
  final Function(LatLng center, double zoom)? onMapPositionChanged;

  const MapWidget({
    super.key,
    required this.mapController,
    required this.currentLocation,
    required this.defaultLocation,
    required this.friends,
    required this.feedPosts,
    required this.currentMode,
    this.initialZoom = 15.0,
    this.onMapPositionChanged,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  double _currentZoom = 15.0;
  void _handleClusterTap(MarkerCluster cluster) {
    ModernPostOverlay.showMultiplePosts(context, cluster.posts);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: FlutterMap(
        mapController: widget.mapController.mapController,
        options: MapOptions(
          initialCenter: widget.currentLocation ?? widget.defaultLocation,
          initialZoom: widget.initialZoom,
          minZoom: 3.0,
          maxZoom: 20.0,
          keepAlive: true,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
          onPositionChanged: widget.onMapPositionChanged != null
              ? (camera, hasGesture) {
                  if (hasGesture) {
                    setState(() => _currentZoom = camera.zoom);
                    widget.onMapPositionChanged!(camera.center, camera.zoom);
                  }
                }
              : null,
        ),
        children: [
          _buildTileLayer(context),
          MarkerLayer(
            markers: MapMarkersBuilder.buildMarkers(
              context: context,
              currentUserLocation: widget.currentLocation,
              friends: widget.friends,
              feedPosts: widget.feedPosts,
              currentMode: widget.currentMode,
              currentZoom: _currentZoom,
              onClusterTap: _handleClusterTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTileLayer(BuildContext context) {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.nctu.minecraft_compass',
      maxZoom: 30,
      minZoom: 0,
      tileBuilder: Theme.of(context).brightness == Brightness.dark
          ? (context, tileWidget, tile) {
              return ColorFiltered(
                colorFilter: const ColorFilter.matrix(<double>[
                  -1.0,
                  0.0,
                  0.0,
                  0.0,
                  255.0,
                  0.0,
                  -1.0,
                  0.0,
                  0.0,
                  255.0,
                  0.0,
                  0.0,
                  -1.0,
                  0.0,
                  255.0,
                  0.0,
                  0.0,
                  0.0,
                  1.0,
                  0.0,
                ]),
                child: tileWidget,
              );
            }
          : null,
    );
  }
}
