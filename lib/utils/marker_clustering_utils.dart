import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:minecraft_compass/models/marker_cluster.dart';
import 'package:minecraft_compass/models/newsfeed_post_model.dart';
import 'package:minecraft_compass/utils/location_utils.dart';
import 'dart:math' as math;

/// Thuật toán clustering đơn giản cho markers
class MarkerClusteringUtils {
  /// Tính cluster distance dựa trên zoom level
  static double getClusterDistance(double zoomLevel) {
    const double base = 5000000; // ~5.13 triệu mét
    const double minDistance = 100; // khoảng cách tối thiểu 100m

    const double k = 2.55; // Hệ số điều chỉnh khoảng cách theo zoom level
    final distance = base / math.pow(zoomLevel, k);
    return distance.clamp(minDistance, distance);
  }

  /// Thực hiện clustering cho danh sách posts
  static List<MarkerCluster> clusterPosts(
    List<NewsfeedPost> posts,
    double zoomLevel,
  ) {
    if (posts.isEmpty) return [];

    final List<MarkerCluster> clusters = [];
    final List<NewsfeedPost> remainingPosts = List.from(posts);
    final double clusterDistance = getClusterDistance(zoomLevel);
    debugPrint('[MarkerClusteringUtils] Cluster distance: $clusterDistance');
    debugPrint('[MarkerClusteringUtils] Zoom level: $zoomLevel');

    while (remainingPosts.isNotEmpty) {
      final NewsfeedPost centerPost = remainingPosts.removeAt(0);
      final LatLng centerPoint = LatLng(
        centerPost.location!.latitude,
        centerPost.location!.longitude,
      );

      final List<NewsfeedPost> clusterPosts = [centerPost];

      // Tìm các posts trong bán kính cluster
      remainingPosts.removeWhere((post) {
        final LatLng postPoint = LatLng(
          post.location!.latitude,
          post.location!.longitude,
        );
        final distance = LocationUtils.calculateDistance(
          centerPoint.latitude,
          centerPoint.longitude,
          postPoint.latitude,
          postPoint.longitude,
        );

        if (distance <= clusterDistance) {
          clusterPosts.add(post);
          return true;
        }
        return false;
      });

      // Tính toán center point của cluster (trung bình các điểm)
      double avgLat = 0;
      double avgLng = 0;
      for (final post in clusterPosts) {
        avgLat += post.location!.latitude;
        avgLng += post.location!.longitude;
      }
      avgLat /= clusterPosts.length;
      avgLng /= clusterPosts.length;

      clusters.add(
        MarkerCluster(
          center: LatLng(avgLat, avgLng),
          posts: clusterPosts,
          radius: clusterDistance,
        ),
      );
    }

    return clusters;
  }
}
