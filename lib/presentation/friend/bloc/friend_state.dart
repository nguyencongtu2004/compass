part of 'friend_bloc.dart';

abstract class FriendState extends Equatable {
  const FriendState();
  @override
  List<Object?> get props => [];
}

class FriendInitial extends FriendState {}

class FriendLoadInProgress extends FriendState {}

class FriendAndRequestsLoadSuccess extends FriendState {
  final List<UserModel> friends;
  final List<UserModel> friendRequests;

  const FriendAndRequestsLoadSuccess({
    required this.friends,
    required this.friendRequests,
  });

  @override
  List<Object?> get props => [friends, friendRequests];
}

class FriendOperationFailure extends FriendState {
  final String message;
  const FriendOperationFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class FriendRequestSent extends FriendState {}

class UserSearchResult extends FriendState {
  final UserModel? user;
  const UserSearchResult(this.user);
  @override
  List<Object?> get props => [user];
}

class FriendsLocationsLoadSuccess extends FriendState {
  final List<UserModel> friends;

  const FriendsLocationsLoadSuccess(this.friends);

  @override
  List<Object?> get props => [friends];
}

class LocationLoadInProgress extends FriendState {}

class LocationLoadSuccess extends FriendState {
  final LocationModel location;

  const LocationLoadSuccess(this.location);

  @override
  List<Object?> get props => [location];
}

class LocationUpdateSuccess extends FriendState {}

class LocationFailure extends FriendState {
  final String message;

  const LocationFailure(this.message);

  @override
  List<Object?> get props => [message];
}
