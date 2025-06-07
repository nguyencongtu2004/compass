part of 'compass_bloc.dart';

abstract class CompassEvent extends Equatable {
  const CompassEvent();
  @override
  List<Object?> get props => [];
}

class StartCompass extends CompassEvent {
  final double? targetLat;
  final double? targetLng;
  final String? friendName;

  const StartCompass({this.targetLat, this.targetLng, this.friendName});

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

class StartRandomCompass extends CompassEvent {
  final String? friendName;

  const StartRandomCompass({this.friendName});

  @override
  List<Object?> get props => [friendName];
}

class UpdateRandomAngle extends CompassEvent {
  final double angle;

  const UpdateRandomAngle(this.angle);

  @override
  List<Object?> get props => [angle];
}

class UpdateTargetLocation extends CompassEvent {
  final double targetLat;
  final double targetLng;
  final String? friendName;

  const UpdateTargetLocation({
    required this.targetLat,
    required this.targetLng,
    this.friendName,
  });

  @override
  List<Object?> get props => [targetLat, targetLng, friendName];
}

class GetCurrentLocationAndUpdate extends CompassEvent {
  final String uid;

  const GetCurrentLocationAndUpdate({required this.uid});

  @override
  List<Object?> get props => [uid];
}
