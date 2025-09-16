class TimetableEntry {
  final String id;
  final String courseId;
  final String roomId;
  final String teacherId;
  final String section;
  final int dayOfWeek; // 1-7 (Monday-Sunday)
  final DateTime startTime;
  final DateTime endTime;
  final String semester;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  TimetableEntry({
    required this.id,
    required this.courseId,
    required this.roomId,
    required this.teacherId,
    required this.section,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.semester,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TimetableEntry.fromMap(Map<String, dynamic> map) {
    return TimetableEntry(
      id: map['id'] ?? '',
      courseId: map['course_id'] ?? '',
      roomId: map['room_id'] ?? '',
      teacherId: map['teacher_id'] ?? '',
      section: map['section'] ?? '',
      dayOfWeek: map['day_of_week'] ?? 1,
      startTime: DateTime.parse(map['start_time'] ?? DateTime.now().toIso8601String()),
      endTime: DateTime.parse(map['end_time'] ?? DateTime.now().toIso8601String()),
      semester: map['semester'] ?? '',
      isActive: map['is_active'] ?? true,
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_id': courseId,
      'room_id': roomId,
      'teacher_id': teacherId,
      'section': section,
      'day_of_week': dayOfWeek,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'semester': semester,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  TimetableEntry copyWith({
    String? id,
    String? courseId,
    String? roomId,
    String? teacherId,
    String? section,
    int? dayOfWeek,
    DateTime? startTime,
    DateTime? endTime,
    String? semester,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TimetableEntry(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      roomId: roomId ?? this.roomId,
      teacherId: teacherId ?? this.teacherId,
      section: section ?? this.section,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      semester: semester ?? this.semester,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get dayName {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[dayOfWeek - 1];
  }

  Duration get duration => endTime.difference(startTime);

  bool isToday() {
    final now = DateTime.now();
    return now.weekday == dayOfWeek;
  }

  bool isNow() {
    final now = DateTime.now();
    final currentTime = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    final start = DateTime(now.year, now.month, now.day, startTime.hour, startTime.minute);
    final end = DateTime(now.year, now.month, now.day, endTime.hour, endTime.minute);
    
    return currentTime.isAfter(start) && currentTime.isBefore(end);
  }
}
