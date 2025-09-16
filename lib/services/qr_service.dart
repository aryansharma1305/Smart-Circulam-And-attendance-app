import 'dart:convert';
import 'dart:math';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';

class QRService {
  static const String _secretKey = 'SmartStudy+SecretKey2024';
  static const int _qrValiditySeconds = 30;

  /// Generate a simple demo QR code for attendance session
  static Future<QRCodeData> generateAttendanceQR({
    required String sessionId,
    required String classId,
    required String teacherId,
    required double latitude,
    required double longitude,
    required String wifiSSID,
    required DateTime timestamp,
  }) async {
    // Create simple QR payload (demo version without encryption)
    final payload = {
      'sessionId': sessionId,
      'classId': classId,
      'teacherId': teacherId,
      'latitude': latitude,
      'longitude': longitude,
      'wifiSSID': wifiSSID,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'demoCode': _generateDemoCode(),
      'expiresAt': timestamp
          .add(Duration(seconds: _qrValiditySeconds))
          .millisecondsSinceEpoch,
    };

    // Simple base64 encoding (demo version)
    final jsonString = jsonEncode(payload);
    final encodedPayload = base64Encode(utf8.encode(jsonString));

    final qrData = QRCodeData(
      data: encodedPayload,
      version: QrVersions.auto,
      size: 200.0,
    );

    return qrData;
  }

  /// Validate scanned QR code (demo version)
  static Future<QRValidationResult> validateAttendanceQR({
    required String scannedData,
    String? expectedSessionId,
    required double currentLatitude,
    required double currentLongitude,
    required String currentWifiSSID,
    required String deviceId,
  }) async {
    try {
      // Decode the payload (demo version)
      final payload = _decodePayload(scannedData);

      if (payload == null) {
        return QRValidationResult(
          isValid: false,
          error: 'Invalid QR code format',
        );
      }

      // Check if QR is expired
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(
        payload['expiresAt'],
      );
      if (DateTime.now().isAfter(expiresAt)) {
        return QRValidationResult(isValid: false, error: 'QR code has expired');
      }

      // Validate session ID if provided
      if (expectedSessionId != null && expectedSessionId.isNotEmpty) {
        if (payload['sessionId'] != expectedSessionId) {
          return QRValidationResult(isValid: false, error: 'Invalid session');
        }
      }

      // Demo validation - always pass for demo purposes
      return QRValidationResult(
        isValid: true,
        sessionId: payload['sessionId'],
        classId: payload['classId'],
        teacherId: payload['teacherId'],
        timestamp: DateTime.fromMillisecondsSinceEpoch(payload['timestamp']),
      );
    } catch (e) {
      return QRValidationResult(
        isValid: false,
        error: 'QR validation failed: ${e.toString()}',
      );
    }
  }

  /// Generate demo code (replaces TOTP)
  static String _generateDemoCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Decode payload from QR code (demo version)
  static Map<String, dynamic>? _decodePayload(String encodedData) {
    try {
      final decodedBytes = base64Decode(encodedData);
      final jsonString = utf8.decode(decodedBytes);
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Calculate distance between two coordinates in meters
  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // Earth's radius in meters

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// Generate QR code widget for display
  static Widget generateQRWidget(QRCodeData qrData) {
    return QrImageView(
      data: qrData.data,
      version: qrData.version,
      size: qrData.size,
    );
  }

  /// Generate rotating QR codes for a session (demo version)
  static Stream<QRCodeData> generateRotatingQR({
    required String sessionId,
    required String classId,
    required String teacherId,
    required double latitude,
    required double longitude,
    required String wifiSSID,
  }) async* {
    while (true) {
      final qrData = await generateAttendanceQR(
        sessionId: sessionId,
        classId: classId,
        teacherId: teacherId,
        latitude: latitude,
        longitude: longitude,
        wifiSSID: wifiSSID,
        timestamp: DateTime.now(),
      );

      yield qrData;

      // Wait for the next rotation period
      await Future.delayed(Duration(seconds: _qrValiditySeconds));
    }
  }
}

class QRCodeData {
  final String data;
  final int version;
  final double size;

  QRCodeData({required this.data, required this.version, required this.size});
}

class QRValidationResult {
  final bool isValid;
  final String? error;
  final String? sessionId;
  final String? classId;
  final String? teacherId;
  final DateTime? timestamp;

  QRValidationResult({
    required this.isValid,
    this.error,
    this.sessionId,
    this.classId,
    this.teacherId,
    this.timestamp,
  });
}
