import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import '../../models/location_model.dart';
import '../../models/user_model.dart';
import '../services/shared_preferences_service.dart';

@lazySingleton
class LocationRepository {
  final FirebaseFirestore _firestore;

  LocationRepository(FirebaseFirestore firestore) : _firestore = firestore;

  /// Lấy vị trí hiện tại từ GPS
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }
    return await Geolocator.getCurrentPosition();
  }

  /// Lấy vị trí cache từ local storage
  Future<Position?> getCachedPosition() async {
    final cachedLocation = await SharedPreferencesService.getCachedLocation();
    if (cachedLocation != null) {
      return Position(
        latitude: cachedLocation['latitude']!,
        longitude: cachedLocation['longitude']!,
        timestamp:
            await SharedPreferencesService.getCachedLocationTimestamp() ??
            DateTime.now(),
        accuracy: 0, // Unknown accuracy for cached location
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    }
    return null;
  }

  /// Lấy vị trí hiện tại hoặc cached location nếu GPS thất bại
  Future<Position> getCurrentOrCachedPosition() async {
    try {
      return await getCurrentPosition();
    } catch (e) {
      final cachedPosition = await getCachedPosition();
      if (cachedPosition != null) {
        return cachedPosition;
      }
      rethrow; // Re-throw the original error if no cached location
    }
  }

  /// Cập nhật vị trí lên Firestore và cache locally
  Future<void> updateLocation(
    String uid,
    double latitude,
    double longitude,
  ) async {
    // Update Firebase
    await _firestore.collection('users').doc(uid).update({
      'currentLocation': {
        'latitude': latitude,
        'longitude': longitude,
        'updatedAt': FieldValue.serverTimestamp(),
      },
    });

    // Cache location locally
    await SharedPreferencesService.cacheLocation(latitude, longitude);
  }

  /// Lắng nghe vị trí của một user
  Stream<LocationModel?> listenToUserLocation(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;

      final data = doc.data()!;
      final locationData = data['currentLocation'];
      if (locationData == null) return null;

      return LocationModel.fromMap(locationData as Map<String, dynamic>);
    });
  }

  /// Lắng nghe vị trí các bạn bè
  Stream<List<UserModel>> listenToFriendsLocations(List<String> friendUids) {
    if (friendUids.isEmpty) return Stream.value([]);

    return _firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: friendUids)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => UserModel.fromMap(doc.id, doc.data()))
              .where((user) => user.currentLocation != null)
              .toList();
        });
  }
}
