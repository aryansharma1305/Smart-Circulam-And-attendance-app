// Demo Analytics Service
// This simulates analytics functionality

import 'dart:math';
import 'dart:developer' as developer;
import '../models/attendance_record.dart';
import '../models/session.dart';
import 'firebase_service.dart';

class AnalyticsService {
  static final Random _random = Random();

  // Generate demo attendance analytics
  static Future<Map<String, dynamic>> getAttendanceAnalytics({
    required String classId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await Future.delayed(Duration(milliseconds: 500));

    // Generate demo data
    final totalSessions = _random.nextInt(20) + 10;
    final totalStudents = _random.nextInt(30) + 20;
    final averageAttendance = 0.75 + _random.nextDouble() * 0.2; // 75-95%

    final dailyAttendance = <String, double>{};
    final currentDate = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);

    var date = currentDate;
    while (date.isBefore(endDateOnly) || date.isAtSameMomentAs(endDateOnly)) {
      if (date.weekday <= 5) {
        // Only weekdays
        dailyAttendance[date.toIso8601String().split('T')[0]] =
            0.6 + _random.nextDouble() * 0.35; // 60-95%
      }
      date = date.add(Duration(days: 1));
    }

    developer.log('Analytics: Generated attendance data for $classId');

    return {
      'totalSessions': totalSessions,
      'totalStudents': totalStudents,
      'averageAttendance': averageAttendance,
      'dailyAttendance': dailyAttendance,
      'attendanceRate': averageAttendance,
      'presentCount': (totalStudents * averageAttendance).round(),
      'absentCount':
          totalStudents - (totalStudents * averageAttendance).round(),
      'trends': {
        'improving': _random.nextBool(),
        'changePercent': (_random.nextDouble() - 0.5) * 10, // -5% to +5%
      },
    };
  }

  // Generate demo student performance
  static Future<Map<String, dynamic>> getStudentPerformance(
    String studentId,
  ) async {
    await Future.delayed(Duration(milliseconds: 300));

    final attendanceRate = 0.7 + _random.nextDouble() * 0.25; // 70-95%
    final totalSessions = _random.nextInt(50) + 30;
    final attendedSessions = (totalSessions * attendanceRate).round();

    developer.log(
      'Analytics: Generated performance data for student $studentId',
    );

    return {
      'studentId': studentId,
      'attendanceRate': attendanceRate,
      'totalSessions': totalSessions,
      'attendedSessions': attendedSessions,
      'missedSessions': totalSessions - attendedSessions,
      'streak': _random.nextInt(15) + 1,
      'lastAttendance': DateTime.now().subtract(
        Duration(days: _random.nextInt(7)),
      ),
      'subjects': _generateSubjectPerformance(),
    };
  }

  // Generate demo class analytics
  static Future<Map<String, dynamic>> getClassAnalytics(String classId) async {
    await Future.delayed(Duration(milliseconds: 400));

    final studentCount = _random.nextInt(25) + 15; // 15-40 students
    final averageAttendance = 0.75 + _random.nextDouble() * 0.2;

    developer.log('Analytics: Generated class analytics for $classId');

    return {
      'classId': classId,
      'studentCount': studentCount,
      'averageAttendance': averageAttendance,
      'topPerformers': _generateTopPerformers(5),
      'attendanceDistribution': _generateAttendanceDistribution(),
      'monthlyTrends': _generateMonthlyTrends(),
      'subjectWiseAttendance': _generateSubjectAttendance(),
    };
  }

  // Generate demo teacher analytics
  static Future<Map<String, dynamic>> getTeacherAnalytics(
    String teacherId,
  ) async {
    await Future.delayed(Duration(milliseconds: 350));

    final totalSessions = _random.nextInt(100) + 50;
    final totalStudents = _random.nextInt(150) + 100;

    developer.log('Analytics: Generated teacher analytics for $teacherId');

    return {
      'teacherId': teacherId,
      'totalSessions': totalSessions,
      'totalStudents': totalStudents,
      'averageClassSize': (totalStudents / totalSessions * 0.8).round(),
      'attendanceRate': 0.75 + _random.nextDouble() * 0.2,
      'classesManaged': _random.nextInt(5) + 2,
      'subjectsTeaching': _generateSubjectsTeaching(),
      'sessionTrends': _generateSessionTrends(),
    };
  }

  // Generate demo system analytics
  static Future<Map<String, dynamic>> getSystemAnalytics() async {
    await Future.delayed(Duration(milliseconds: 600));

    developer.log('Analytics: Generated system analytics');

    return {
      'totalUsers': _random.nextInt(500) + 200,
      'totalSessions': _random.nextInt(1000) + 500,
      'totalAttendanceRecords': _random.nextInt(5000) + 2000,
      'systemUptime': 0.95 + _random.nextDouble() * 0.04, // 95-99%
      'averageResponseTime': _random.nextInt(200) + 50, // 50-250ms
      'errorRate': _random.nextDouble() * 0.02, // 0-2%
      'peakUsageHours': [9, 10, 11, 14, 15, 16],
      'dailyActiveUsers': _random.nextInt(100) + 50,
      'weeklyGrowth': (_random.nextDouble() - 0.5) * 20, // -10% to +10%
    };
  }

  // Helper methods for generating demo data
  static List<Map<String, dynamic>> _generateTopPerformers(int count) {
    return List.generate(
      count,
      (index) => {
        'studentId': 'student_${index + 1}',
        'name': 'Student ${index + 1}',
        'attendanceRate': 0.85 + _random.nextDouble() * 0.14, // 85-99%
      },
    );
  }

  static Map<String, int> _generateAttendanceDistribution() {
    return {
      '90-100%': _random.nextInt(10) + 5,
      '80-89%': _random.nextInt(8) + 3,
      '70-79%': _random.nextInt(6) + 2,
      '60-69%': _random.nextInt(4) + 1,
      'Below 60%': _random.nextInt(3),
    };
  }

  static List<Map<String, dynamic>> _generateMonthlyTrends() {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    return months
        .map(
          (month) => {
            'month': month,
            'attendance': 0.7 + _random.nextDouble() * 0.25,
          },
        )
        .toList();
  }

  static Map<String, double> _generateSubjectAttendance() {
    final subjects = [
      'Mathematics',
      'Physics',
      'Chemistry',
      'Biology',
      'English',
    ];
    return Map.fromEntries(
      subjects.map(
        (subject) => MapEntry(subject, 0.7 + _random.nextDouble() * 0.25),
      ),
    );
  }

  static Map<String, double> _generateSubjectPerformance() {
    final subjects = ['Math', 'Science', 'English', 'History'];
    return Map.fromEntries(
      subjects.map(
        (subject) => MapEntry(subject, 0.65 + _random.nextDouble() * 0.3),
      ),
    );
  }

  static List<String> _generateSubjectsTeaching() {
    final allSubjects = [
      'Mathematics',
      'Physics',
      'Chemistry',
      'Biology',
      'English',
      'History',
    ];
    final count = _random.nextInt(3) + 1; // 1-3 subjects
    allSubjects.shuffle(_random);
    return allSubjects.take(count).toList();
  }

  static List<Map<String, dynamic>> _generateSessionTrends() {
    return List.generate(
      7,
      (index) => {
        'day': DateTime.now().subtract(Duration(days: 6 - index)).day,
        'sessions': _random.nextInt(5) + 1,
        'attendance': 0.7 + _random.nextDouble() * 0.25,
      },
    );
  }

  // Additional methods for compatibility
  static Future<List<Map<String, dynamic>>> getSessionAnalytics(String teacherId) async {
    await Future.delayed(Duration(milliseconds: 400));
    
    return List.generate(10, (index) => {
      'sessionId': 'session_$index',
      'subject': ['Math', 'Science', 'English'][index % 3],
      'date': DateTime.now().subtract(Duration(days: index)).toIso8601String(),
      'totalStudents': 25 + _random.nextInt(10),
      'presentStudents': 20 + _random.nextInt(8),
      'attendanceRate': 0.7 + _random.nextDouble() * 0.25,
      'isAtRisk': _random.nextBool(),
    });
  }

    static Future<List<Map<String, dynamic>>> getStudentAnalytics(String classId) async {
    await Future.delayed(Duration(milliseconds: 350));
    
    return List.generate(20, (index) => {
      'studentId': 'student_$index',
      'name': 'Student ${index + 1}',
      'attendanceRate': 0.6 + _random.nextDouble() * 0.35,
      'totalSessions': 30 + _random.nextInt(20),
      'attendedSessions': 20 + _random.nextInt(15),
      'isAtRisk': _random.nextBool(),
      'subjects': ['Math', 'Science', 'English'],
    });
  }

    static Future<List<Map<String, dynamic>>> getAttendanceTrends(String classId) async {
    await Future.delayed(Duration(milliseconds: 300));
    
    return List.generate(30, (index) => {
      'date': DateTime.now().subtract(Duration(days: index)).toIso8601String(),
      'attendancePercentage': 0.7 + _random.nextDouble() * 0.25,
      'totalStudents': 25,
      'presentStudents': 18 + _random.nextInt(7),
    });
  }

    static Future<String> exportToCSV(Map<String, dynamic> data, String format) async {
    await Future.delayed(Duration(milliseconds: 500));
    
    // Generate demo CSV content
    final csvContent = '''
Date,Subject,Total Students,Present Students,Attendance Rate
${DateTime.now().toIso8601String().split('T')[0]},Mathematics,25,23,92%
${DateTime.now().subtract(Duration(days: 1)).toIso8601String().split('T')[0]},Science,25,21,84%
${DateTime.now().subtract(Duration(days: 2)).toIso8601String().split('T')[0]},English,25,24,96%
''';
    
    developer.log('Analytics: Exported CSV data ($format format)');
    return csvContent;
  }