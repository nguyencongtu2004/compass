part of 'compass_bloc.dart';

abstract class CompassState extends Equatable {
  const CompassState();
  @override
  List<Object?> get props => [];
}

class CompassInitial extends CompassState {}

class CompassLoading extends CompassState {}

class CompassReady extends CompassState {
  final double? heading;
  final double? currentLat;
  final double? currentLng;
  final double? targetLat;
  final double? targetLng;
  final String? friendName;
  final double? distance;
  final double compassAngle;

  const CompassReady({
    this.heading,
    this.currentLat,
    this.currentLng,
    this.targetLat,
    this.targetLng,
    this.friendName,
    this.distance,
    required this.compassAngle,
  });

  @override
  List<Object?> get props => [
    heading,
    currentLat,
    currentLng,
    targetLat,
    targetLng,
    friendName,
    distance,
    compassAngle,
  ];

  CompassReady copyWith({
    double? heading,
    double? currentLat,
    double? currentLng,
    double? targetLat,
    double? targetLng,
    String? friendName,
    double? distance,
    double? compassAngle,
  }) {
    return CompassReady(
      heading: heading ?? this.heading,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      targetLat: targetLat ?? this.targetLat,
      targetLng: targetLng ?? this.targetLng,
      friendName: friendName ?? this.friendName,
      distance: distance ?? this.distance,
      compassAngle: compassAngle ?? this.compassAngle,
    );
  }
}

class CompassError extends CompassState {
  final String message;

  const CompassError(this.message);

  @override
  List<Object?> get props => [message];
}
