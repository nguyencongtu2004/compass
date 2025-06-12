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
  final LatLng? currentLocation; // Vị trí hiện tại từ GPS
  final LatLng?
  cachedUserLocation; // Vị trí người dùng từ cache (không phải fitBounds)
  final LatLng
  defaultLocation; // Vị trí mặc định từ cache fitBounds hoặc fallback
  final List<UserModel> friends;
  final List<NewsfeedPost> feedPosts;
  final MapDisplayMode currentMode;
  final bool firstTimeLoadExplore;
  final List<LatLng> boundsPoints;
  final bool shouldAutoFitBounds;
  final double initialZoom;

  const MapReady({
    this.currentLocation,
    this.cachedUserLocation,
    required this.defaultLocation,
    required this.friends,
    required this.feedPosts,
    required this.currentMode,
    required this.firstTimeLoadExplore,
    required this.boundsPoints,
    required this.shouldAutoFitBounds,
    this.initialZoom = 15.0,
  });

  @override
  List<Object?> get props => [
    currentLocation,
    cachedUserLocation,
    defaultLocation,
    friends,
    feedPosts,
    currentMode,
    firstTimeLoadExplore,
    boundsPoints,
    shouldAutoFitBounds,
    initialZoom,
  ];
  MapReady copyWith({
    LatLng? currentLocation,
    LatLng? cachedUserLocation,
    LatLng? defaultLocation,
    List<UserModel>? friends,
    List<NewsfeedPost>? feedPosts,
    MapDisplayMode? currentMode,
    bool? firstTimeLoadExplore,
    List<LatLng>? boundsPoints,
    bool? shouldAutoFitBounds,
    double? initialZoom,
  }) {
    return MapReady(
      currentLocation: currentLocation ?? this.currentLocation,
      cachedUserLocation: cachedUserLocation ?? this.cachedUserLocation,
      defaultLocation: defaultLocation ?? this.defaultLocation,
      friends: friends ?? this.friends,
      feedPosts: feedPosts ?? this.feedPosts,
      currentMode: currentMode ?? this.currentMode,
      firstTimeLoadExplore: firstTimeLoadExplore ?? this.firstTimeLoadExplore,
      boundsPoints: boundsPoints ?? this.boundsPoints,
      shouldAutoFitBounds: shouldAutoFitBounds ?? this.shouldAutoFitBounds,
      initialZoom: initialZoom ?? this.initialZoom,
    );
  }
  /// Lấy các điểm để fit bounds dựa trên mode hiện tại
  List<LatLng> getPointsForCurrentMode() {
    final allPoints = <LatLng>[];

    // Ưu tiên vị trí hiện tại từ GPS, nếu không có thì dùng cached user location
    final userLocation = currentLocation ?? cachedUserLocation;
    if (userLocation != null) {
      allPoints.add(userLocation);
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
