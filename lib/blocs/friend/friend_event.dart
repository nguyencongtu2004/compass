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

class FindUserByEmail extends FriendEvent {
  final String email;
  const FindUserByEmail(this.email);
  @override
  List<Object?> get props => [email];
}
