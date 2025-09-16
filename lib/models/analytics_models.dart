// Analytics Models for Demo

class TeacherAnalytics {
  final String teacherId;
  final String name;
  final int totalSessions;
  final int totalStudents;
  final double averageAttendance;
  final List<String> subjects;
  final Map<String, dynamic> performance;

  TeacherAnalytics({
    required this.teacherId,
    required this.name,
    required this.totalSessions,
    required this.totalStudents,
    required this.averageAttendance,
    required this.subjects,
    required this.performance,
  });
}

class SessionAnalytics {
  final String sessionId;
  final String subject;
  final DateTime date;
  final int totalStudents;
  final int presentStudents;
  final double attendanceRate;
  final bool isAtRisk;

  SessionAnalytics({
    required this.sessionId,
    required this.subject,
    required this.date,
    required this.totalStudents,
    required this.presentStudents,
    required this.attendanceRate,
    required this.isAtRisk,
  });
}

class StudentAnalytics {
  final String studentId;
  final String name;
  final double attendanceRate;
  final int totalSessions;
  final int attendedSessions;
  final bool isAtRisk;
  final List<String> subjects;

  StudentAnalytics({
    required this.studentId,
    required this.name,
    required this.attendanceRate,
    required this.totalSessions,
    required this.attendedSessions,
    required this.isAtRisk,
    required this.subjects,
  });
}

class AttendanceTrend {
  final DateTime date;
  final double attendancePercentage;
  final int totalStudents;
  final int presentStudents;

  AttendanceTrend({
    required this.date,
    required this.attendancePercentage,
    required this.totalStudents,
    required this.presentStudents,
  });
}

enum ExportFormat { detailed, summary, studentWise }
