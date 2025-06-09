import 'package:equatable/equatable.dart';
import 'package:minecraft_compass/utils/prase_utils.dart';

class LocationModel extends Equatable {
  final double latitude;
  final double longitude;
  final DateTime updatedAt;
  final String? locationName;

  const LocationModel({
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
    this.locationName,
  });

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      updatedAt: PraseUtils.parseDateTime(map['updatedAt']),
      locationName: map['locationName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'updatedAt': updatedAt,
      'locationName': locationName,
    };
  }

  LocationModel copyWith({
    double? latitude,
    double? longitude,
    DateTime? updatedAt,
    String? locationName,
  }) {
    return LocationModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      updatedAt: updatedAt ?? this.updatedAt,
      locationName: locationName ?? this.locationName,
    );
  }

  @override
  List<Object?> get props => [latitude, longitude, updatedAt, locationName];
}
