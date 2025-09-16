// Demo Background Sync Service
// This simulates background synchronization without external dependencies

import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/widgets.dart';
import 'simple_storage_service.dart';
import 'firebase_attendance_service_demo.dart';
import '../models/attendance_record.dart';
import '../models/session.dart';

class BackgroundSyncService {
  static Timer? _syncTimer;
  static bool _isRunning = false;

  static Future<void> startBackgroundSync() async {
    if (_isRunning) return;

    _isRunning = true;
    developer.log('BackgroundSync: Starting sync...');

    // Start periodic sync every 30 seconds
    _syncTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _performSync();
    });

    // Perform initial sync
    await _performSync();
  }

  static Future<void> stopBackgroundSync() async {
    _syncTimer?.cancel();
    _isRunning = false;
    developer.log('BackgroundSync: Stopped');
  }

  static Future<void> _performSync() async {
    try {
      developer.log('BackgroundSync: Performing sync...');

      // Simulate network check
      await Future.delayed(Duration(milliseconds: 100));

      // Sync pending attendance records
      await _syncPendingAttendance();

      // Sync pending sessions
      await _syncPendingSessions();

      developer.log('BackgroundSync: Sync completed successfully');
    } catch (e) {
      developer.log('BackgroundSync: Sync failed - $e');
    }
  }

  static Future<void> _syncPendingAttendance() async {
    try {
      final pendingRecords =
          await SimpleStorageService.getPendingAttendanceRecords();

      for (final record in pendingRecords) {
        try {
          await FirebaseAttendanceService.createAttendanceRecord(
            sessionId: record.sessionId,
            studentId: record.studentId,
            studentName: record.studentName,
            timestamp: record.timestamp,
            latitude: record.latitude,
            longitude: record.longitude,
            method: record.method,
          );

          // Remove from pending after successful sync
          await SimpleStorageService.removePendingAttendanceRecord(record.id);
          developer.log(
            'BackgroundSync: Synced attendance record ${record.id}',
          );
        } catch (e) {
          developer.log(
            'BackgroundSync: Failed to sync attendance record - $e',
          );
        }
      }
    } catch (e) {
      developer.log(
        'BackgroundSync: Failed to get pending attendance records - $e',
      );
    }
  }

  static Future<void> _syncPendingSessions() async {
    try {
      final pendingSessions = await SimpleStorageService.getPendingSessions();

      for (final sessionData in pendingSessions) {
        try {
          await FirebaseAttendanceService.createSession(
            teacherId: sessionData['teacherId'],
            classId: sessionData['classId'],
            subject: sessionData['subject'],
            startTime: DateTime.parse(sessionData['startTime']),
            endTime: DateTime.parse(sessionData['endTime']),
            latitude: sessionData['latitude'],
            longitude: sessionData['longitude'],
            radius: sessionData['radius'],
          );

          // Remove from pending after successful sync
          await SimpleStorageService.removePendingSession(sessionData['id']);
          developer.log('BackgroundSync: Synced session ${sessionData['id']}');
        } catch (e) {
          developer.log('BackgroundSync: Failed to sync session - $e');
        }
      }
    } catch (e) {
      developer.log('BackgroundSync: Failed to get pending sessions - $e');
    }
  }

  // Queue attendance record for sync
  static Future<void> queueAttendanceRecord(AttendanceRecord record) async {
    try {
      await SimpleStorageService.addPendingAttendanceRecord(record);
      developer.log('BackgroundSync: Queued attendance record for sync');

      // Try immediate sync
      await _performSync();
    } catch (e) {
      developer.log('BackgroundSync: Failed to queue attendance record - $e');
    }
  }

  // Queue session for sync
  static Future<void> queueSession(Map<String, dynamic> sessionData) async {
    try {
      await SimpleStorageService.addPendingSession(sessionData);
      developer.log('BackgroundSync: Queued session for sync');

      // Try immediate sync
      await _performSync();
    } catch (e) {
      developer.log('BackgroundSync: Failed to queue session - $e');
    }
  }

  // Force sync now
  static Future<void> syncNow() async {
    await _performSync();
  }

  // Get sync status
  static bool get isRunning => _isRunning;

  static Future<Map<String, dynamic>> getSyncStatus() async {
    final pendingAttendance =
        await SimpleStorageService.getPendingAttendanceRecords();
    final pendingSessions = await SimpleStorageService.getPendingSessions();

    return {
      'isRunning': _isRunning,
      'pendingAttendanceCount': pendingAttendance.length,
      'pendingSessionsCount': pendingSessions.length,
      'lastSyncTime': DateTime.now().toIso8601String(),
    };
  }
}
