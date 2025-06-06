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
    on<LoadFriends>(_onLoadFriends);
    on<LoadFriendRequests>(_onLoadFriendRequests);
    on<SendFriendRequest>(_onSendFriendRequest);
    on<AcceptFriendRequest>(_onAcceptFriendRequest);
    on<DeclineFriendRequest>(_onDeclineFriendRequest);
    on<FindUserByEmail>(_onFindUserByEmail);
    on<ListenToFriendsLocations>(_onListenToFriendsLocations);
    on<FriendsLocationsUpdated>(_onFriendsLocationsUpdated);
    on<StopListeningToFriendsLocations>(_onStopListeningToFriendsLocations);
    on<GetCurrentLocation>(_onGetCurrentLocation);
    on<UpdateLocation>(_onUpdateLocation);
    on<GetCurrentLocationAndUpdate>(_onGetCurrentLocationAndUpdate);
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

  void _onListenToFriendsLocations(
    ListenToFriendsLocations event,
    Emitter<FriendState> emit,
  ) {
    _friendsLocationSubscription?.cancel();
    _friendsLocationSubscription = _locationRepository
        .listenToFriendsLocations(event.friendUids)
        .listen((friends) {
          add(FriendsLocationsUpdated(friends));
        });
  }

  void _onFriendsLocationsUpdated(
    FriendsLocationsUpdated event,
    Emitter<FriendState> emit,
  ) {
    emit(FriendsLocationsLoadSuccess(event.friends));
  }

  void _onStopListeningToFriendsLocations(
    StopListeningToFriendsLocations event,
    Emitter<FriendState> emit,
  ) {
    _friendsLocationSubscription?.cancel();
    _friendsLocationSubscription = null;
  }

  void _onGetCurrentLocation(
    GetCurrentLocation event,
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
      emit(LocationLoadSuccess(location));
    } catch (e) {
      emit(LocationFailure(e.toString()));
    }
  }

  void _onUpdateLocation(
    UpdateLocation event,
    Emitter<FriendState> emit,
  ) async {
    try {
      await _locationRepository.updateLocation(
        event.uid,
        event.latitude,
        event.longitude,
      );
      emit(LocationUpdateSuccess());
    } catch (e) {
      emit(LocationFailure(e.toString()));
    }
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

  @override
  Future<void> close() {
    _friendsLocationSubscription?.cancel();
    return super.close();
  }
}
