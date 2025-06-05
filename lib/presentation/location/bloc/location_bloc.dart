import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/location_repository.dart';
import '../../../core/models/location_model.dart';
import '../../../core/models/user_model.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepository _locationRepository;
  StreamSubscription<List<UserModel>>? _friendsLocationSubscription;
  LocationBloc({LocationRepository? locationRepository})
    : _locationRepository = locationRepository ?? LocationRepository(),
      super(LocationInitial()) {
    on<GetCurrentLocation>(_onGetCurrentLocation);
    on<UpdateLocation>(_onUpdateLocation);
    on<GetCurrentLocationAndUpdate>(_onGetCurrentLocationAndUpdate);
    on<ListenToFriendsLocations>(_onListenToFriendsLocations);
    on<FriendsLocationsUpdated>(_onFriendsLocationsUpdated);
    on<StopListeningToFriendsLocations>(_onStopListeningToFriendsLocations);
  }

  void _onGetCurrentLocation(
    GetCurrentLocation event,
    Emitter<LocationState> emit,
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
    Emitter<LocationState> emit,
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
    Emitter<LocationState> emit,
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

  void _onListenToFriendsLocations(
    ListenToFriendsLocations event,
    Emitter<LocationState> emit,
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
    Emitter<LocationState> emit,
  ) {
    emit(FriendsLocationsLoadSuccess(event.friends));
  }

  void _onStopListeningToFriendsLocations(
    StopListeningToFriendsLocations event,
    Emitter<LocationState> emit,
  ) {
    _friendsLocationSubscription?.cancel();
    _friendsLocationSubscription = null;
  }

  @override
  Future<void> close() {
    _friendsLocationSubscription?.cancel();
    return super.close();
  }
}
