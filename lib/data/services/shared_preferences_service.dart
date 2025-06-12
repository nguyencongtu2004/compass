import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesKeys {
  static const tokenKey = 'TOKEN';
  static const lastKnownLatitude = 'LAST_KNOWN_LATITUDE';
  static const lastKnownLongitude = 'LAST_KNOWN_LONGITUDE';
  static const lastKnownLocationTimestamp = 'LAST_KNOWN_LOCATION_TIMESTAMP';
  static const lastFitBoundsLatitude = 'LAST_FIT_BOUNDS_LATITUDE';
  static const lastFitBoundsLongitude = 'LAST_FIT_BOUNDS_LONGITUDE';
  static const lastFitBoundsZoom = 'LAST_FIT_BOUNDS_ZOOM';
  static const lastFitBoundsTimestamp = 'LAST_FIT_BOUNDS_TIMESTAMP';
}

class SharedPreferencesService {
  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  static Future<void> setInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  static Future<double?> getDouble(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }

  static Future<void> setDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  static Future<bool> containsKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // Location caching methods
  static Future<void> cacheLocation(double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(SharedPreferencesKeys.lastKnownLatitude, latitude);
    await prefs.setDouble(SharedPreferencesKeys.lastKnownLongitude, longitude);
    await prefs.setInt(
      SharedPreferencesKeys.lastKnownLocationTimestamp,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<Map<String, double>?> getCachedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final latitude = prefs.getDouble(SharedPreferencesKeys.lastKnownLatitude);
    final longitude = prefs.getDouble(SharedPreferencesKeys.lastKnownLongitude);

    if (latitude != null && longitude != null) {
      return {'latitude': latitude, 'longitude': longitude};
    }
    return null;
  }

  static Future<DateTime?> getCachedLocationTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(
      SharedPreferencesKeys.lastKnownLocationTimestamp,
    );
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }
  static Future<void> clearCachedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(SharedPreferencesKeys.lastKnownLatitude);
    await prefs.remove(SharedPreferencesKeys.lastKnownLongitude);
    await prefs.remove(SharedPreferencesKeys.lastKnownLocationTimestamp);
  }

  // FitBounds caching methods
  static Future<void> cacheFitBounds(
    double latitude,
    double longitude,
    double zoom,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(
      SharedPreferencesKeys.lastFitBoundsLatitude,
      latitude,
    );
    await prefs.setDouble(
      SharedPreferencesKeys.lastFitBoundsLongitude,
      longitude,
    );
    await prefs.setDouble(SharedPreferencesKeys.lastFitBoundsZoom, zoom);
    await prefs.setInt(
      SharedPreferencesKeys.lastFitBoundsTimestamp,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<Map<String, double>?> getCachedFitBounds() async {
    final prefs = await SharedPreferences.getInstance();
    final latitude = prefs.getDouble(
      SharedPreferencesKeys.lastFitBoundsLatitude,
    );
    final longitude = prefs.getDouble(
      SharedPreferencesKeys.lastFitBoundsLongitude,
    );
    final zoom = prefs.getDouble(SharedPreferencesKeys.lastFitBoundsZoom);

    if (latitude != null && longitude != null && zoom != null) {
      return {'latitude': latitude, 'longitude': longitude, 'zoom': zoom};
    }
    return null;
  }

  static Future<DateTime?> getCachedFitBoundsTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(
      SharedPreferencesKeys.lastFitBoundsTimestamp,
    );
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  static Future<void> clearCachedFitBounds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(SharedPreferencesKeys.lastFitBoundsLatitude);
    await prefs.remove(SharedPreferencesKeys.lastFitBoundsLongitude);
    await prefs.remove(SharedPreferencesKeys.lastFitBoundsZoom);
    await prefs.remove(SharedPreferencesKeys.lastFitBoundsTimestamp);
  }
}
