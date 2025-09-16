import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart' as app_user;

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _uuid = const Uuid();

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Create a new session for a class
  Future<Map<String, dynamic>> createSession({
    required String subjectId,
    required String classId,
    required String teacherId,
    required GeoPoint location,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final sessionId = _uuid.v4();
      final sessionCode = _generateSessionCode();
      
      final sessionData = {
        'id': sessionId,
        'subjectId': subjectId,
        'classId': classId,
        'teacherId': teacherId,
        'sessionCode': sessionCode,
        'location': location,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('sessions').doc(sessionId).set(sessionData);
      
      return {
        'success': true,
        'sessionId': sessionId,
        'sessionCode': sessionCode,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Mark attendance for a student
  Future<Map<String, dynamic>> markAttendance({
    required String sessionId,
    required String sessionCode,
    required String studentId,
    required Position currentLocation,
  }) async {
    try {
      // Fetch the session
      final sessionDoc = await _firestore.collection('sessions').doc(sessionId).get();
      
      if (!sessionDoc.exists) {
        return {
          'success': false,
          'error': 'Session not found',
        };
      }
      
      final sessionData = sessionDoc.data()!;
      
      // Verify session code
      if (sessionData['sessionCode'] != sessionCode) {
        return {
          'success': false,
          'error': 'Invalid session code',
        };
      }
      
      // Verify session is active
      if (sessionData['status'] != 'active') {
        return {
          'success': false,
          'error': 'Session is not active',
        };
      }
      
      // Verify location (within 100 meters)
      final sessionLocation = sessionData['location'] as GeoPoint;
      final distance = Geolocator.distanceBetween(
        sessionLocation.latitude,
        sessionLocation.longitude,
        currentLocation.latitude,
        currentLocation.longitude,
      );
      
      // Determine attendance status based on time and location
      String status = 'present';
      
      // If distance is greater than 100 meters, mark as remote
      if (distance > 100) {
        status = 'remote';
      }
      
      // If current time is after session start time + 10 minutes, mark as late
      final sessionStartTime = (sessionData['startTime'] as Timestamp).toDate();
      final lateThreshold = sessionStartTime.add(const Duration(minutes: 10));
      
      if (DateTime.now().isAfter(lateThreshold) && status == 'present') {
        status = 'late';
      }
      
      // Record the attendance
      final attendanceId = _uuid.v4();
      final attendanceData = {
        'id': attendanceId,
        'sessionId': sessionId,
        'studentId': studentId,
        'status': status,
        'location': GeoPoint(currentLocation.latitude, currentLocation.longitude),
        'timestamp': FieldValue.serverTimestamp(),
        'distance': distance,
      };
      
      await _firestore.collection('attendance').doc(attendanceId).set(attendanceData);
      
      return {
        'success': true,
        'attendanceId': attendanceId,
        'status': status,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Get attendance history for a student
  Future<List<Map<String, dynamic>>> getStudentAttendanceHistory(String studentId) async {
    try {
      final querySnapshot = await _firestore
          .collection('attendance')
          .where('studentId', isEqualTo: studentId)
          .orderBy('timestamp', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      return [];
    }
  }

  // Get attendance for a specific session
  Future<List<Map<String, dynamic>>> getSessionAttendance(String sessionId) async {
    try {
      final querySnapshot = await _firestore
          .collection('attendance')
          .where('sessionId', isEqualTo: sessionId)
          .get();
      
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      return [];
    }
  }

  // End a session
  Future<bool> endSession(String sessionId) async {
    try {
      await _firestore.collection('sessions').doc(sessionId).update({
        'status': 'completed',
        'endedAt': FieldValue.serverTimestamp(),
      });
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Generate a random 6-digit session code
  String _generateSessionCode() {
    return (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
  }
}