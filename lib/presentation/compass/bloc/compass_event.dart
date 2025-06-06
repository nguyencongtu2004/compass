part of 'compass_bloc.dart';

abstract class CompassEvent extends Equatable {
  const CompassEvent();
  @override
  List<Object?> get props => [];
}

class StartCompass extends CompassEvent {
  final double targetLat;
  final double targetLng;
  final String? friendName;

  const StartCompass({
    required this.targetLat,
    required this.targetLng,
    this.friendName,
  });

  @override
  List<Object?> get props => [targetLat, targetLng, friendName];
}

class UpdateCompassHeading extends CompassEvent {
  final double heading;

  const UpdateCompassHeading(this.heading);

  @override
  List<Object?> get props => [heading];
}

class UpdateCurrentLocation extends CompassEvent {
  final double latitude;
  final double longitude;

  const UpdateCurrentLocation({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}

class RefreshCurrentLocation extends CompassEvent {
  const RefreshCurrentLocation();
}

class StopCompass extends CompassEvent {
  const StopCompass();
}
