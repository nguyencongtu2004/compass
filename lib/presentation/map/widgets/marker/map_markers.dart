import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:minecraft_compass/models/marker_cluster.dart';
import 'package:minecraft_compass/models/newsfeed_post_model.dart';
import 'package:minecraft_compass/models/user_model.dart';
import 'package:minecraft_compass/presentation/map/widgets/marker/location/current_user_location_marker.dart';
import 'package:minecraft_compass/presentation/map/widgets/marker/location/friend_location_marker.dart';
import 'package:minecraft_compass/presentation/map/widgets/marker/post/multi_post_marker.dart';
import 'package:minecraft_compass/presentation/map/widgets/marker/post/single_post_marker.dart';
import 'package:minecraft_compass/utils/marker_clustering_utils.dart';
import '../map_toggle_switch.dart';

class MapMarkersBuilder {
  static List<Marker> buildMarkers({
    required BuildContext context,
    required LatLng? currentLocation,
    required List<UserModel> friends,
    required List<NewsfeedPost> feedPosts,
    required MapDisplayMode currentMode,
    required double currentZoom,
    required Function(MarkerCluster) onClusterTap,
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
          child: CurrentUserLocationMarker(),
        ),
      );
    }

    // Hiển thị markers dựa trên chế độ hiện tại
    switch (currentMode) {
      case MapDisplayMode.locations:
        // Marker cho bạn bè (không clustering)
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
              child: FriendLocationMarker(friend: friend),
            ),
          );
        }
        break;
      case MapDisplayMode.friends:
      case MapDisplayMode.explore:
        // Sử dụng clustering cho feed posts
        final clusters = MarkerClusteringUtils.clusterPosts(
          feedPosts,
          currentZoom,
        );
        for (final cluster in clusters) {
          final isSingle = cluster.count == 1;
          markers.add(
            Marker(
              point: cluster.center,
              width: 120,
              height: 120,
              rotate: true,
              alignment: Alignment.center,
              child: isSingle
                  ? SinglePostMarker(
                      post: cluster.posts.first,
                      onTap: () => onClusterTap(cluster),
                    )
                  : MultiPostMarker(
                      cluster: cluster,
                      onTap: () => onClusterTap(cluster),
                    ),
            ),
          );
        }
        break;
    }

    return markers;
  }
}
