part of 'friend_bloc.dart';

abstract class FriendEvent extends Equatable {
  const FriendEvent();
  @override
  List<Object?> get props => [];
}

class LoadFriends extends FriendEvent {
  final String myUid;
  const LoadFriends(this.myUid);
  @override
  List<Object?> get props => [myUid];
}

class LoadFriendRequests extends FriendEvent {
  final String myUid;
  const LoadFriendRequests(this.myUid);
  @override
  List<Object?> get props => [myUid];
}

class LoadFriendsAndRequests extends FriendEvent {
  final String myUid;
  const LoadFriendsAndRequests(this.myUid);
  @override
  List<Object?> get props => [myUid];
}

class SendFriendRequest extends FriendEvent {
  final String fromUid;
  final String toUid;
  const SendFriendRequest({required this.fromUid, required this.toUid});
  @override
  List<Object?> get props => [fromUid, toUid];
}

class AcceptFriendRequest extends FriendEvent {
  final String myUid;
  final String requesterUid;
  const AcceptFriendRequest({required this.myUid, required this.requesterUid});
  @override
  List<Object?> get props => [myUid, requesterUid];
}

class DeclineFriendRequest extends FriendEvent {
  final String myUid;
  final String requesterUid;
  const DeclineFriendRequest({required this.myUid, required this.requesterUid});
  @override
  List<Object?> get props => [myUid, requesterUid];
}

class RemoveFriend extends FriendEvent {
  final String myUid;
  final String friendUid;
  const RemoveFriend({required this.myUid, required this.friendUid});
  @override
  List<Object?> get props => [myUid, friendUid];
}

class FindUserByEmail extends FriendEvent {
  final String email;
  const FindUserByEmail(this.email);
  @override
  List<Object?> get props => [email];
}

class ClearSearchResults extends FriendEvent {
  const ClearSearchResults();
}

class ListenToFriendsLocations extends FriendEvent {
  final List<String> friendUids;

  const ListenToFriendsLocations(this.friendUids);

  @override
  List<Object?> get props => [friendUids];
}

class FriendsLocationsUpdated extends FriendEvent {
  final List<UserModel> friends;

  const FriendsLocationsUpdated(this.friends);

  @override
  List<Object?> get props => [friends];
}

class GetCurrentLocation extends FriendEvent {
  const GetCurrentLocation();
}

class UpdateLocation extends FriendEvent {
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

class GetCachedLocation extends FriendEvent {
  const GetCachedLocation();
}
