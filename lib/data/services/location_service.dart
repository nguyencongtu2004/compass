import '../repositories/location_repository.dart';
import '../../models/location_model.dart';

class LocationService {
  final LocationRepository _locationRepository;

  LocationService({LocationRepository? locationRepository})
    : _locationRepository = locationRepository ?? LocationRepository();

  /// Lấy vị trí hiện tại
  Future<LocationModel> getCurrentLocation() async {
    final position = await _locationRepository.getCurrentPosition();
    return LocationModel(
      latitude: position.latitude,
      longitude: position.longitude,
      updatedAt: DateTime.now(),
    );
  }

  /// Cập nhật vị trí lên Firestore
  Future<void> updateLocation(
    String uid,
    double latitude,
    double longitude,
  ) async {
    await _locationRepository.updateLocation(uid, latitude, longitude);
  }

  /// Lấy vị trí hiện tại và cập nhật lên Firestore cùng lúc
  Future<LocationModel> getCurrentLocationAndUpdate(String uid) async {
    final position = await _locationRepository.getCurrentPosition();
    final location = LocationModel(
      latitude: position.latitude,
      longitude: position.longitude,
      updatedAt: DateTime.now(),
    );

    // Cập nhật vị trí lên Firestore
    await _locationRepository.updateLocation(
      uid,
      position.latitude,
      position.longitude,
    );

    return location;
  }
}
