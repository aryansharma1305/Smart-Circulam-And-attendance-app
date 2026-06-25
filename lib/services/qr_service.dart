import 'dart:math';

import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';

import 'secure_qr_service.dart';

class QRService {
  // Local/dev fallback only. In production, QR signing must happen in a trusted
  // backend using a secret that is never shipped in the Flutter client.
  static const String _secretKey = String.fromEnvironment(
    'QR_SIGNING_SECRET',
    defaultValue: 'dev-only-qr-signing-secret-change-before-production',
  );
  static const int _qrValiditySeconds = 30;
  static final SecureQrService _secureQrService = SecureQrService(
    signingSecret: _secretKey,
    tokenTtl: const Duration(seconds: _qrValiditySeconds),
  );

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
    final encodedPayload = _secureQrService.issueToken(
      sessionId: sessionId,
      timetableEntryId: classId,
      teacherId: teacherId,
      issuedAt: timestamp,
    );

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
      final validation = _secureQrService.verifyToken(
        rawToken: scannedData,
        expectedSessionId: expectedSessionId,
      );

      if (!validation.isValid || validation.token == null) {
        return QRValidationResult(
          isValid: false,
          error: validation.error ?? 'Invalid QR code',
        );
      }

      final token = validation.token!;
      return QRValidationResult(
        isValid: true,
        sessionId: token.sessionId,
        classId: token.timetableEntryId,
        teacherId: token.teacherId,
        timestamp: token.issuedAt,
      );
    } catch (e) {
      return QRValidationResult(
        isValid: false,
        error: 'QR validation failed: ${e.toString()}',
      );
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
