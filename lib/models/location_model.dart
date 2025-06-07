import 'package:equatable/equatable.dart';
import 'package:minecraft_compass/utils/prase_utils.dart';

class LocationModel extends Equatable {
  final double latitude;
  final double longitude;
  final DateTime updatedAt;

  const LocationModel({
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
  });
  
  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      updatedAt: PraseUtils.parseDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'updatedAt': updatedAt,
    };
  }

  @override
  List<Object?> get props => [latitude, longitude, updatedAt];
}
