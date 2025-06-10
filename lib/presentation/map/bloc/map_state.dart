part of 'map_bloc.dart';

abstract class MapState extends Equatable {
  const MapState();
  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {
  const MapInitial();
}

class MapLoading extends MapState {
  const MapLoading();
}

class MapReady extends MapState {
  final LatLng? currentLocation;
  final LatLng defaultLocation;
  final List<UserModel> friends;
  final List<NewsfeedPost> feedPosts;
  final MapDisplayMode currentMode;
  final bool firstTimeLoadExplore;
  final List<LatLng> boundsPoints;
  final bool shouldAutoFitBounds;

  const MapReady({
    this.currentLocation,
    required this.defaultLocation,
    required this.friends,
    required this.feedPosts,
    required this.currentMode,
    required this.firstTimeLoadExplore,
    required this.boundsPoints,
    required this.shouldAutoFitBounds,
  });

  @override
  List<Object?> get props => [
    currentLocation,
    defaultLocation,
    friends,
    feedPosts,
    currentMode,
    firstTimeLoadExplore,
    boundsPoints,
    shouldAutoFitBounds,
  ];

  MapReady copyWith({
    LatLng? currentLocation,
    LatLng? defaultLocation,
    List<UserModel>? friends,
    List<NewsfeedPost>? feedPosts,
    MapDisplayMode? currentMode,
    bool? firstTimeLoadExplore,
    List<LatLng>? boundsPoints,
    bool? shouldAutoFitBounds,
  }) {
    return MapReady(
      currentLocation: currentLocation ?? this.currentLocation,
      defaultLocation: defaultLocation ?? this.defaultLocation,
      friends: friends ?? this.friends,
      feedPosts: feedPosts ?? this.feedPosts,
      currentMode: currentMode ?? this.currentMode,
      firstTimeLoadExplore: firstTimeLoadExplore ?? this.firstTimeLoadExplore,
      boundsPoints: boundsPoints ?? this.boundsPoints,
      shouldAutoFitBounds: shouldAutoFitBounds ?? this.shouldAutoFitBounds,
    );
  }

  /// Lấy các điểm để fit bounds dựa trên mode hiện tại
  List<LatLng> getPointsForCurrentMode() {
    final allPoints = <LatLng>[];

    // Thêm vị trí hiện tại
    if (currentLocation != null) {
      allPoints.add(currentLocation!);
    }

    // Thêm vị trí dựa trên chế độ hiện tại
    switch (currentMode) {
      case MapDisplayMode.locations:
        // Thêm vị trí bạn bè (chỉ khi có bạn bè)
        if (friends.isNotEmpty) {
          allPoints.addAll(
            friends
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
        if (feedPosts.isNotEmpty) {
          allPoints.addAll(
            feedPosts
                .where((post) => post.location != null)
                .map(
                  (post) =>
                      LatLng(post.location!.latitude, post.location!.longitude),
                ),
          );
        }
        break;
    }

    return allPoints;
  }
}

class MapError extends MapState {
  final String message;

  const MapError(this.message);

  @override
  List<Object?> get props => [message];
}
