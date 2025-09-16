// Demo Firebase Attendance Service
// This is a demo implementation that simulates Firebase functionality

import 'dart:async';
import 'dart:math';
import '../models/attendance_record.dart';
import '../models/session.dart';

class FirebaseAttendanceService {
  static final Map<String, Session> _sessions = {};
  static final Map<String, List<AttendanceRecord>> _attendanceRecords = {};
  static final StreamController<Session?> _sessionController =
      StreamController<Session?>.broadcast();
  static final StreamController<List<AttendanceRecord>> _attendanceController =
      StreamController<List<AttendanceRecord>>.broadcast();

  // Create a new session
  static Future<String> createSession({
    required String timetableId,
    required DateTime date,
    required double latitude,
    required double longitude,
    required double radius,
  }) async {
    await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay

    final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    final qrSeed = 'qr_${Random().nextInt(999999).toString().padLeft(6, '0')}';

    final session = Session(
      id: sessionId,
      timetableId: timetableId,
      date: date,
      state: SessionState.live,
      qrSeed: qrSeed,
      qrExpiry: DateTime.now().add(Duration(minutes: 30)),
      proximityPolicy: {
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
      },
      stats: {
        'total_students': 0,
        'present_students': 0,
        'absent_students': 0,
        'late_students': 0,
      },
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _sessions[sessionId] = session;
    _attendanceRecords[sessionId] = [];
    _sessionController.add(session);

    return sessionId;
  }

  // Get session by ID
  static Future<Session?> getSession(String sessionId) async {
    await Future.delayed(Duration(milliseconds: 200));
    return _sessions[sessionId];
  }

  // Get session by QR seed
  static Future<Session?> getSessionByQRToken(String qrSeed) async {
    await Future.delayed(Duration(milliseconds: 200));
    return _sessions.values.firstWhere(
      (session) => session.qrSeed == qrSeed && session.isLive,
      orElse: () => throw Exception('Session not found or inactive'),
    );
  }

  // Watch session changes
  static Stream<Session?> watchSession(String sessionId) {
    return _sessionController.stream.where(
      (session) => session?.id == sessionId,
    );
  }

  // Watch session attendance
  static Stream<List<AttendanceRecord>> watchSessionAttendance(
    String sessionId,
  ) {
    return _attendanceController.stream.where(
      (records) => records.isNotEmpty && records.first.sessionId == sessionId,
    );
  }

  // Create attendance record
  static Future<void> createAttendanceRecord({
    required String sessionId,
    required String studentId,
    required DateTime timestamp,
    required double latitude,
    required double longitude,
    required String method,
  }) async {
    await Future.delayed(Duration(milliseconds: 300));

    final record = AttendanceRecord(
      id: 'attendance_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: sessionId,
      studentId: studentId,
      status: AttendanceStatus.present,
      method: AttendanceMethod.values.firstWhere(
        (m) => m.toString().split('.').last == method,
        orElse: () => AttendanceMethod.qr,
      ),
      timestamp: timestamp,
      metadata: {'latitude': latitude, 'longitude': longitude},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _attendanceRecords[sessionId] ??= [];
    _attendanceRecords[sessionId]!.add(record);
    _attendanceController.add(_attendanceRecords[sessionId]!);
  }

  // End session
  static Future<void> endSession(String qrSeed) async {
    await Future.delayed(Duration(milliseconds: 200));

    final session = _sessions.values.firstWhere(
      (s) => s.qrSeed == qrSeed,
      orElse: () => throw Exception('Session not found'),
    );

    final updatedSession = session.copyWith(
      state: SessionState.closed,
      updatedAt: DateTime.now(),
    );

    _sessions[session.id] = updatedSession;
    _sessionController.add(updatedSession);
  }

  // Get attendance records for session
  static Future<List<AttendanceRecord>> getSessionAttendance(
    String sessionId,
  ) async {
    await Future.delayed(Duration(milliseconds: 200));
    return _attendanceRecords[sessionId] ?? [];
  }

  // Cleanup
  static void dispose() {
    _sessionController.close();
    _attendanceController.close();
  }
}
