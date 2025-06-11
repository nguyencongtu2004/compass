import 'package:latlong2/latlong.dart';
import 'package:minecraft_compass/models/newsfeed_post_model.dart';

/// Model đại diện cho một cluster của markers
class MarkerCluster {
  final LatLng center;
  final List<NewsfeedPost> posts;
  final double radius;

  const MarkerCluster({
    required this.center,
    required this.posts,
    required this.radius,
  });

  int get count => posts.length;
}
