import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/friend_repository.dart';
import '../../../data/repositories/location_repository.dart';
import '../../../models/user_model.dart';
import '../../../models/location_model.dart';

part 'friend_event.dart';
part 'friend_state.dart';

class FriendBloc extends Bloc<FriendEvent, FriendState> {
  final FriendRepository _friendRepository;
  final LocationRepository _locationRepository;
  StreamSubscription<List<UserModel>>? _friendsLocationSubscription;

  FriendBloc({
    FriendRepository? friendRepository,
    LocationRepository? locationRepository,
  }) : _friendRepository = friendRepository ?? FriendRepository(),
       _locationRepository = locationRepository ?? LocationRepository(),
       super(FriendInitial()) {
    on<LoadFriendsAndRequests>(_onLoadFriendsAndRequests);
    on<SendFriendRequest>(_onSendFriendRequest);
    on<AcceptFriendRequest>(_onAcceptFriendRequest);
    on<DeclineFriendRequest>(_onDeclineFriendRequest);
    on<RemoveFriend>(_onRemoveFriend);
    on<FindUserByEmail>(_onFindUserByEmail);
    on<StopListeningToFriendsLocations>(_onStopListeningToFriendsLocations);
    on<GetCurrentLocationAndUpdate>(_onGetCurrentLocationAndUpdate);
  }

  void _onSendFriendRequest(
    SendFriendRequest event,
    Emitter<FriendState> emit,
  ) async {
    try {
      await _friendRepository.sendFriendRequest(
        fromUid: event.fromUid,
        toUid: event.toUid,
      );
      emit(FriendRequestSent());
    } catch (e) {
      emit(FriendOperationFailure(e.toString()));
    }
  }

  void _onAcceptFriendRequest(
    AcceptFriendRequest event,
    Emitter<FriendState> emit,
  ) async {
    try {
      await _friendRepository.acceptFriendRequest(
        myUid: event.myUid,
        requesterUid: event.requesterUid,
      );
      // Reload both friends and friend requests without showing loading
      final results = await Future.wait([
        _friendRepository.getFriends(event.myUid),
        _friendRepository.getFriendRequests(event.myUid),
      ]);

      final friends = results[0];
      final friendRequests = results[1];

      emit(
        FriendAndRequestsLoadSuccess(
          friends: friends,
          friendRequests: friendRequests,
        ),
      );
    } catch (e) {
      emit(FriendOperationFailure(e.toString()));
    }
  }

  void _onDeclineFriendRequest(
    DeclineFriendRequest event,
    Emitter<FriendState> emit,
  ) async {
    try {
      await _friendRepository.declineFriendRequest(
        myUid: event.myUid,
        requesterUid: event.requesterUid,
      );
      // Reload both friends and friend requests without showing loading
      final results = await Future.wait([
        _friendRepository.getFriends(event.myUid),
        _friendRepository.getFriendRequests(event.myUid),
      ]);

      final friends = results[0];
      final friendRequests = results[1];

      emit(
        FriendAndRequestsLoadSuccess(
          friends: friends,
          friendRequests: friendRequests,
        ),
      );
    } catch (e) {
      emit(FriendOperationFailure(e.toString()));
    }
  }

  void _onFindUserByEmail(
    FindUserByEmail event,
    Emitter<FriendState> emit,
  ) async {
    // Không emit FriendLoadInProgress để tránh che mất UI hiện tại
    try {
      final user = await _friendRepository.findUserByEmail(event.email);
      emit(UserSearchResult(user)); // Emit dù user có null hay không
    } catch (e) {
      emit(FriendOperationFailure(e.toString()));
    }
  }

  void _onStopListeningToFriendsLocations(
    StopListeningToFriendsLocations event,
    Emitter<FriendState> emit,
  ) {
    _friendsLocationSubscription?.cancel();
    _friendsLocationSubscription = null;
  }

  void _onGetCurrentLocationAndUpdate(
    GetCurrentLocationAndUpdate event,
    Emitter<FriendState> emit,
  ) async {
    emit(LocationLoadInProgress());
    try {
      final position = await _locationRepository.getCurrentPosition();
      final location = LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        updatedAt: DateTime.now(),
      );

      // Cập nhật vị trí lên Firestore
      await _locationRepository.updateLocation(
        event.uid,
        position.latitude,
        position.longitude,
      );

      emit(LocationLoadSuccess(location));
      emit(LocationUpdateSuccess());
    } catch (e) {
      emit(LocationFailure(e.toString()));
    }
  }

  void _onRemoveFriend(RemoveFriend event, Emitter<FriendState> emit) async {
    try {
      await _friendRepository.removeFriend(
        myUid: event.myUid,
        friendUid: event.friendUid,
      );
      // Reload both friends and friend requests without showing loading
      final results = await Future.wait([
        _friendRepository.getFriends(event.myUid),
        _friendRepository.getFriendRequests(event.myUid),
      ]);

      final friends = results[0];
      final friendRequests = results[1];

      emit(
        FriendAndRequestsLoadSuccess(
          friends: friends,
          friendRequests: friendRequests,
        ),
      );
    } catch (e) {
      emit(FriendOperationFailure(e.toString()));
    }
  }

  void _onLoadFriendsAndRequests(
    LoadFriendsAndRequests event,
    Emitter<FriendState> emit,
  ) async {
    emit(FriendLoadInProgress());
    try {
      // Load both friends and friend requests concurrently
      final results = await Future.wait([
        _friendRepository.getFriends(event.myUid),
        _friendRepository.getFriendRequests(event.myUid),
      ]);

      final friends = results[0];
      final friendRequests = results[1];

      emit(
        FriendAndRequestsLoadSuccess(
          friends: friends,
          friendRequests: friendRequests,
        ),
      );
    } catch (e) {
      emit(FriendOperationFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _friendsLocationSubscription?.cancel();
    return super.close();
  }
}
