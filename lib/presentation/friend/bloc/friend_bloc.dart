import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/friend_repository.dart';
import '../../../models/user_model.dart';

part 'friend_event.dart';
part 'friend_state.dart';

class FriendBloc extends Bloc<FriendEvent, FriendState> {
  final FriendRepository _friendRepository;
  StreamSubscription<List<UserModel>>? _friendsLocationSubscription;

  // Store current friends and requests state để restore sau khi search
  FriendAndRequestsLoadSuccess? _currentFriendsState;

  FriendBloc({FriendRepository? friendRepository})
    : _friendRepository = friendRepository ?? FriendRepository(),
      super(FriendInitial()) {
    on<LoadFriendsAndRequests>(_onLoadFriendsAndRequests);
    on<SendFriendRequest>(_onSendFriendRequest);
    on<AcceptFriendRequest>(_onAcceptFriendRequest);
    on<DeclineFriendRequest>(_onDeclineFriendRequest);
    on<RemoveFriend>(_onRemoveFriend);
    on<FindUserByEmail>(_onFindUserByEmail);
    on<ClearSearchResults>(_onClearSearchResults);
    on<FriendResetRequested>(_onFriendResetRequested);
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

      final newState = FriendAndRequestsLoadSuccess(
        friends: friends,
        friendRequests: friendRequests,
      );

      // Update stored state
      _currentFriendsState = newState;

      emit(newState);
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

      final newState = FriendAndRequestsLoadSuccess(
        friends: friends,
        friendRequests: friendRequests,
      );

      // Update stored state
      _currentFriendsState = newState;

      emit(newState);
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
      final user = await _friendRepository.findUserByEmailAndUsername(
        event.email,
      );
      emit(UserSearchResult(user)); // Emit dù user có null hay không
    } catch (e) {
      // Emit UserSearchResult(null) thay vì FriendOperationFailure để maintain consistent flow
      emit(UserSearchResult(null));
    }
  }

  void _onClearSearchResults(
    ClearSearchResults event,
    Emitter<FriendState> emit,
  ) {
    // Return to the last successful friends state if available
    if (_currentFriendsState != null) {
      emit(_currentFriendsState!);
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

      final newState = FriendAndRequestsLoadSuccess(
        friends: friends,
        friendRequests: friendRequests,
      );

      // Update stored state
      _currentFriendsState = newState;

      emit(newState);
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

      final newState = FriendAndRequestsLoadSuccess(
        friends: friends,
        friendRequests: friendRequests,
      );

      // Store current state for restoration after search
      _currentFriendsState = newState;

      emit(newState);
    } catch (e) {
      emit(FriendOperationFailure(e.toString()));
    }
  }

  void _onFriendResetRequested(
    FriendResetRequested event,
    Emitter<FriendState> emit,
  ) {
    // Emit initial state to reset the friend list and requests
    emit(FriendInitial());
  }

  @override
  Future<void> close() {
    _friendsLocationSubscription?.cancel();
    return super.close();
  }
}
