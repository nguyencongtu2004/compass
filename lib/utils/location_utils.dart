import 'dart:math' as math;

class LocationUtils {
  /// Tính bearing (góc) từ vị trí hiện tại đến vị trí đích
  /// Trả về góc từ 0-360 độ (0 = Bắc, 90 = Đông, 180 = Nam, 270 = Tây)
  static double calculateBearing(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    final startLatRad = _degreesToRadians(startLat);
    final startLngRad = _degreesToRadians(startLng);
    final endLatRad = _degreesToRadians(endLat);
    final endLngRad = _degreesToRadians(endLng);

    final deltaLng = endLngRad - startLngRad;

    final y = math.sin(deltaLng) * math.cos(endLatRad);
    final x =
        math.cos(startLatRad) * math.sin(endLatRad) -
        math.sin(startLatRad) * math.cos(endLatRad) * math.cos(deltaLng);

    final bearingRad = math.atan2(y, x);
    final bearingDeg = _radiansToDegrees(bearingRad);

    // Chuyển đổi từ -180/+180 sang 0-360
    return (bearingDeg + 360) % 360;
  }

  /// Tính khoảng cách giữa hai điểm (theo công thức Haversine)
  /// Trả về khoảng cách tính bằng mét
  static double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    const double earthRadius = 6371000; // Bán kính Trái Đất tính bằng mét

    final startLatRad = _degreesToRadians(startLat);
    final startLngRad = _degreesToRadians(startLng);
    final endLatRad = _degreesToRadians(endLat);
    final endLngRad = _degreesToRadians(endLng);

    final deltaLat = endLatRad - startLatRad;
    final deltaLng = endLngRad - startLngRad;

    final a =
        math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(startLatRad) *
            math.cos(endLatRad) *
            math.sin(deltaLng / 2) *
            math.sin(deltaLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  /// Chuyển đổi từ độ sang radian
  static double _degreesToRadians(double degrees) =>
      degrees * (math.pi / 180.0);

  /// Chuyển đổi từ radian sang độ
  static double _radiansToDegrees(double radians) =>
      radians * (180.0 / math.pi);

  /// Format khoảng cách cho hiển thị
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      final distanceInKm = distanceInMeters / 1000;
      return '${distanceInKm.toStringAsFixed(1)} km';
    }
  }
}
