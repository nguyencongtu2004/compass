import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../core/models/location_model.dart';
import '../core/models/user_model.dart';

class LocationRepository {
  final FirebaseFirestore _firestore;

  LocationRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

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

  /// Cập nhật vị trí lên Firestore
  Future<void> updateLocation(
    String uid,
    double latitude,
    double longitude,
  ) async {
    await _firestore.collection('users').doc(uid).update({
      'currentLocation': {
        'latitude': latitude,
        'longitude': longitude,
        'updatedAt': FieldValue.serverTimestamp(),
      },
    });
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
