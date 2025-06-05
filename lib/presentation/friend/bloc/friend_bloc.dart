import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/friend_repository.dart';
import '../../../core/models/user_model.dart';

part 'friend_event.dart';
part 'friend_state.dart';

class FriendBloc extends Bloc<FriendEvent, FriendState> {
  final FriendRepository _friendRepository;

  FriendBloc({FriendRepository? friendRepository})
    : _friendRepository = friendRepository ?? FriendRepository(),
      super(FriendInitial()) {
    on<LoadFriends>(_onLoadFriends);
    on<LoadFriendRequests>(_onLoadFriendRequests);
    on<SendFriendRequest>(_onSendFriendRequest);
    on<AcceptFriendRequest>(_onAcceptFriendRequest);
    on<DeclineFriendRequest>(_onDeclineFriendRequest);
    on<FindUserByEmail>(_onFindUserByEmail);
  }

  void _onLoadFriends(LoadFriends event, Emitter<FriendState> emit) async {
    emit(FriendLoadInProgress());
    try {
      final friends = await _friendRepository.getFriends(event.myUid);
      emit(FriendLoadSuccess(friends));
    } catch (e) {
      emit(FriendOperationFailure(e.toString()));
    }
  }

  void _onLoadFriendRequests(
    LoadFriendRequests event,
    Emitter<FriendState> emit,
  ) async {
    emit(FriendLoadInProgress());
    try {
      final requests = await _friendRepository.getFriendRequests(event.myUid);
      emit(FriendRequestLoadSuccess(requests));
    } catch (e) {
      emit(FriendOperationFailure(e.toString()));
    }
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
      // Reload friend requests
      add(LoadFriendRequests(event.myUid));
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
      // Reload friend requests
      add(LoadFriendRequests(event.myUid));
    } catch (e) {
      emit(FriendOperationFailure(e.toString()));
    }
  }

  void _onFindUserByEmail(
    FindUserByEmail event,
    Emitter<FriendState> emit,
  ) async {
    emit(FriendLoadInProgress());
    try {
      final user = await _friendRepository.findUserByEmail(event.email);
      emit(UserSearchResult(user));
    } catch (e) {
      emit(FriendOperationFailure(e.toString()));
    }
  }
}
