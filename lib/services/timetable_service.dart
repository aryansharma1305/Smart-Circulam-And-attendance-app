import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

class TimetableService {
  final FirebaseFirestore _firestore;
  final auth.FirebaseAuth? _auth;

  TimetableService({FirebaseFirestore? firestore, auth.FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth;

  // Get current user ID
  String? get currentUserId => _auth?.currentUser?.uid;

  // Create a new class schedule
  Future<void> createClassSchedule({
    required String courseId,
    required String courseName,
    required String teacherId,
    required String teacherName,
    required String roomNumber,
    required DateTime startTime,
    required DateTime endTime,
    required List<String> studentIds,
    required List<String> weekdays,
  }) async {
    // Validate inputs
    if (startTime.isAfter(endTime)) {
      throw Exception('Start time must be before end time');
    }

    if (weekdays.isEmpty) {
      throw Exception('At least one weekday must be selected');
    }

    // Create the class schedule document
    await _firestore.collection('class_schedules').add({
      'courseId': courseId,
      'courseName': courseName,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'roomNumber': roomNumber,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'studentIds': studentIds,
      'weekdays': weekdays,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update an existing class schedule
  Future<void> updateClassSchedule({
    required String scheduleId,
    String? courseName,
    String? roomNumber,
    DateTime? startTime,
    DateTime? endTime,
    List<String>? studentIds,
    List<String>? weekdays,
  }) async {
    final Map<String, dynamic> updates = {};

    if (courseName != null) updates['courseName'] = courseName;
    if (roomNumber != null) updates['roomNumber'] = roomNumber;
    if (startTime != null) updates['startTime'] = Timestamp.fromDate(startTime);
    if (endTime != null) updates['endTime'] = Timestamp.fromDate(endTime);
    if (studentIds != null) updates['studentIds'] = studentIds;
    if (weekdays != null) updates['weekdays'] = weekdays;
    updates['updatedAt'] = FieldValue.serverTimestamp();

    if (updates.isNotEmpty) {
      await _firestore
          .collection('class_schedules')
          .doc(scheduleId)
          .update(updates);
    }
  }

  // Delete a class schedule
  Future<void> deleteClassSchedule(String scheduleId) async {
    await _firestore.collection('class_schedules').doc(scheduleId).delete();
  }

  // Get all class schedules for a teacher
  Future<List<Map<String, dynamic>>> getTeacherSchedules(
    String teacherId,
  ) async {
    final snapshot = await _firestore
        .collection('class_schedules')
        .where('teacherId', isEqualTo: teacherId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {'id': doc.id, ...data};
    }).toList();
  }

  // Get all class schedules for a student
  Future<List<Map<String, dynamic>>> getStudentSchedules(
    String studentId,
  ) async {
    final snapshot = await _firestore
        .collection('class_schedules')
        .where('studentIds', arrayContains: studentId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {'id': doc.id, ...data};
    }).toList();
  }

  // Get class schedules for a specific day
  Future<List<Map<String, dynamic>>> getSchedulesForDay(
    String userId,
    String role,
    String weekday,
  ) async {
    Query query;

    if (role == 'teacher') {
      query = _firestore
          .collection('class_schedules')
          .where('teacherId', isEqualTo: userId)
          .where('weekdays', arrayContains: weekday);
    } else {
      query = _firestore
          .collection('class_schedules')
          .where('studentIds', arrayContains: userId)
          .where('weekdays', arrayContains: weekday);
    }

    final snapshot = await query.get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {'id': doc.id, ...data};
    }).toList();
  }

  // Get upcoming classes for today
  Future<List<Map<String, dynamic>>> getTodayClasses(
    String userId,
    String role,
  ) async {
    final now = DateTime.now();
    final weekday = _getWeekdayString(now.weekday);

    final schedules = await getSchedulesForDay(userId, role, weekday);

    // Filter and sort classes that haven't ended yet
    final upcomingClasses = schedules.where((schedule) {
      final endTime = (schedule['endTime'] as Timestamp).toDate();
      final today = DateTime(
        now.year,
        now.month,
        now.day,
        endTime.hour,
        endTime.minute,
      );
      return today.isAfter(now);
    }).toList();

    // Sort by start time
    upcomingClasses.sort((a, b) {
      final aStart = (a['startTime'] as Timestamp).toDate();
      final bStart = (b['startTime'] as Timestamp).toDate();
      return aStart.compareTo(bStart);
    });

    return upcomingClasses;
  }

  // Helper method to convert weekday int to string
  String _getWeekdayString(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
  }

  // Get color for a course (consistent color based on course name)
  Color getCourseColor(String courseName) {
    // Generate a consistent color based on the course name
    final int hashCode = courseName.hashCode;
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.deepPurple,
    ];

    return colors[hashCode.abs() % colors.length];
  }
}
