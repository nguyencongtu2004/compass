part of 'location_bloc.dart';

abstract class LocationState extends Equatable {
  const LocationState();
  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {}

class LocationLoadInProgress extends LocationState {}

class LocationLoadSuccess extends LocationState {
  final LocationModel location;

  const LocationLoadSuccess(this.location);

  @override
  List<Object?> get props => [location];
}

class LocationUpdateSuccess extends LocationState {}

class FriendsLocationsLoadSuccess extends LocationState {
  final List<UserModel> friends;

  const FriendsLocationsLoadSuccess(this.friends);

  @override
  List<Object?> get props => [friends];
}

class LocationFailure extends LocationState {
  final String message;

  const LocationFailure(this.message);

  @override
  List<Object?> get props => [message];
}
