part of 'location_bloc.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();
  @override
  List<Object?> get props => [];
}

class GetCurrentLocation extends LocationEvent {
  const GetCurrentLocation();
}

class UpdateLocation extends LocationEvent {
  final String uid;
  final double latitude;
  final double longitude;

  const UpdateLocation({
    required this.uid,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [uid, latitude, longitude];
}

class GetCurrentLocationAndUpdate extends LocationEvent {
  final String uid;

  const GetCurrentLocationAndUpdate({required this.uid});

  @override
  List<Object?> get props => [uid];
}

class ListenToFriendsLocations extends LocationEvent {
  final List<String> friendUids;

  const ListenToFriendsLocations(this.friendUids);

  @override
  List<Object?> get props => [friendUids];
}

class FriendsLocationsUpdated extends LocationEvent {
  final List<UserModel> friends;

  const FriendsLocationsUpdated(this.friends);

  @override
  List<Object?> get props => [friends];
}

class StopListeningToFriendsLocations extends LocationEvent {
  const StopListeningToFriendsLocations();
}
