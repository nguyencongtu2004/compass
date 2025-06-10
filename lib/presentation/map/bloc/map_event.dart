part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();
  @override
  List<Object?> get props => [];
}

class MapInitialized extends MapEvent {
  const MapInitialized();
}

class MapModeChanged extends MapEvent {
  final MapDisplayMode mode;

  const MapModeChanged(this.mode);

  @override
  List<Object?> get props => [mode];
}

class MapLocationUpdated extends MapEvent {
  final LatLng? location;

  const MapLocationUpdated(this.location);

  @override
  List<Object?> get props => [location];
}

class MapFriendsUpdated extends MapEvent {
  final List<UserModel> friends;

  const MapFriendsUpdated(this.friends);

  @override
  List<Object?> get props => [friends];
}

class MapFeedPostsUpdated extends MapEvent {
  final List<NewsfeedPost> feedPosts;

  const MapFeedPostsUpdated(this.feedPosts);

  @override
  List<Object?> get props => [feedPosts];
}

class MapPositionChanged extends MapEvent {
  final LatLng center;
  final double zoom;

  const MapPositionChanged({required this.center, required this.zoom});

  @override
  List<Object?> get props => [center, zoom];
}

class MapAutoFitBoundsRequested extends MapEvent {
  const MapAutoFitBoundsRequested();
}

class MapLoadPostsByLocationRequested extends MapEvent {
  final LatLng center;
  final double zoom;

  const MapLoadPostsByLocationRequested({
    required this.center,
    required this.zoom,
  });

  @override
  List<Object?> get props => [center, zoom];
}

class MapDefaultLocationSet extends MapEvent {
  final LatLng defaultLocation;

  const MapDefaultLocationSet(this.defaultLocation);

  @override
  List<Object?> get props => [defaultLocation];
}

class MapResetRequested extends MapEvent {
  const MapResetRequested();
}
