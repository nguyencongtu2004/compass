import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:minecraft_compass/models/newsfeed_post_model.dart';
import 'package:minecraft_compass/models/user_model.dart';

import 'map_markers.dart';

class MapWidget extends StatelessWidget {
  final AnimatedMapController mapController;
  final LatLng? currentLocation;
  final LatLng defaultLocation;
  final List<UserModel> friends;
  final List<NewsfeedPost> feedPosts;
  final bool showFriends;

  const MapWidget({
    super.key,
    required this.mapController,
    required this.currentLocation,
    required this.defaultLocation,
    required this.friends,
    required this.feedPosts,
    required this.showFriends,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: FlutterMap(
        mapController: mapController.mapController,
        options: MapOptions(
          initialCenter: currentLocation ?? defaultLocation,
          initialZoom: 15.0,
          minZoom: 5.0,
          maxZoom: 30.0,
          keepAlive: true,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
        ),
        children: [
          _buildTileLayer(context),
          MarkerLayer(
            markers: MapMarkersBuilder.buildMarkers(
              context: context,
              currentLocation: currentLocation,
              friends: friends,
              feedPosts: feedPosts,
              showFriends: showFriends,
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
      maxZoom: 19,
      minZoom: 5,
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
