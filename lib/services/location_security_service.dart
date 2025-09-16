// Demo Location Security Service
// This simulates location and security functionality without external dependencies

import 'dart:async';
import 'dart:math';
import 'dart:developer' as developer;

class LocationSecurityService {
  static const double _demoLatitude = 28.6139; // Delhi coordinates
  static const double _demoLongitude = 77.2090;

  // Demo location permission check
  static Future<bool> checkLocationPermission() async {
    await Future.delayed(Duration(milliseconds: 500));
    developer.log('Demo: Location permission granted');
    return true;
  }

  // Demo location fetch
  static Future<LocationData> getCurrentLocation() async {
    await Future.delayed(Duration(milliseconds: 1000));

    // Add some random variation to simulate real location
    final random = Random();
    final lat = _demoLatitude + (random.nextDouble() - 0.5) * 0.001;
    final lng = _demoLongitude + (random.nextDouble() - 0.5) * 0.001;

    return LocationData(
      latitude: lat,
      longitude: lng,
      accuracy: 5.0,
      timestamp: DateTime.now(),
    );
  }

  // Demo distance calculation
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Simple distance calculation (not accurate, just for demo)
    final deltaLat = lat2 - lat1;
    final deltaLon = lon2 - lon1;
    return sqrt(deltaLat * deltaLat + deltaLon * deltaLon) *
        111000; // Rough conversion to meters
  }

  // Demo location validation
  static Future<LocationValidationResult> validateLocation({
    required double targetLatitude,
    required double targetLongitude,
    required double allowedRadius,
  }) async {
    final currentLocation = await getCurrentLocation();
    final distance = calculateDistance(
      currentLocation.latitude,
      currentLocation.longitude,
      targetLatitude,
      targetLongitude,
    );

    final isValid = distance <= allowedRadius;

    return LocationValidationResult(
      isValid: isValid,
      currentLatitude: currentLocation.latitude,
      currentLongitude: currentLocation.longitude,
      distance: distance,
      allowedRadius: allowedRadius,
      timestamp: DateTime.now(),
    );
  }

  // Demo connectivity check
  static Future<String> checkConnectivity() async {
    await Future.delayed(Duration(milliseconds: 200));
    return 'wifi'; // Always return connected for demo
  }

  // Demo security check
  static Future<SecurityCheckResult> performSecurityCheck({
    required double targetLatitude,
    required double targetLongitude,
    required double allowedRadius,
  }) async {
    final locationResult = await validateLocation(
      targetLatitude: targetLatitude,
      targetLongitude: targetLongitude,
      allowedRadius: allowedRadius,
    );

    final connectivity = await checkConnectivity();

    return SecurityCheckResult(
      locationValid: locationResult.isValid,
      networkConnected: connectivity != 'none',
      permissionsGranted: true, // Always true for demo
      deviceTrusted: true, // Always true for demo
      overallValid: locationResult.isValid,
      locationData: locationResult,
      connectivity: connectivity,
      timestamp: DateTime.now(),
    );
  }

  // Demo permission request
  static Future<Map<String, bool>> requestPermissions() async {
    await Future.delayed(Duration(milliseconds: 1000));

    return {'location': true, 'camera': true, 'storage': true};
  }

  // Additional methods for compatibility
  static Future<WifiResult> getCurrentWifiSSID() async {
    await Future.delayed(Duration(milliseconds: 300));

    return WifiResult(
      success: true,
      ssid: 'Demo_WiFi_Network',
      bssid: '00:11:22:33:44:55',
      error: null,
    );
  }
}

// Data classes
class LocationData {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
  });
}

class LocationValidationResult {
  final bool isValid;
  final double currentLatitude;
  final double currentLongitude;
  final double distance;
  final double allowedRadius;
  final DateTime timestamp;

  LocationValidationResult({
    required this.isValid,
    required this.currentLatitude,
    required this.currentLongitude,
    required this.distance,
    required this.allowedRadius,
    required this.timestamp,
  });
}

class SecurityCheckResult {
  final bool locationValid;
  final bool networkConnected;
  final bool permissionsGranted;
  final bool deviceTrusted;
  final bool overallValid;
  final LocationValidationResult locationData;
  final String connectivity;
  final DateTime timestamp;

  SecurityCheckResult({
    required this.locationValid,
    required this.networkConnected,
    required this.permissionsGranted,
    required this.deviceTrusted,
    required this.overallValid,
    required this.locationData,
    required this.connectivity,
    required this.timestamp,
  });
}

// Helper function for square root
double sqrt(double x) {
  if (x < 0) return double.nan;
  if (x == 0) return 0;

  double guess = x / 2;
  double prevGuess = 0;

  while ((guess - prevGuess).abs() > 0.0001) {
    prevGuess = guess;
    guess = (guess + x / guess) / 2;
  }

  return guess;
}

// Additional data classes
class WifiResult {
  final bool success;
  final String? ssid;
  final String? bssid;
  final String? error;

  WifiResult({required this.success, this.ssid, this.bssid, this.error});
}
