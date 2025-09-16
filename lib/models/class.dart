class ClassSchedule {
  final String classId;
  final String subject;
  final String teacherId;
  final String section;
  final String room;
  final List<ScheduleSlot> schedule;
  final String? description;

  ClassSchedule({
    required this.classId,
    required this.subject,
    required this.teacherId,
    required this.section,
    required this.room,
    required this.schedule,
    this.description,
  });

  factory ClassSchedule.fromJson(Map<String, dynamic> json) {
    return ClassSchedule(
      classId: json['classId'] ?? '',
      subject: json['subject'] ?? '',
      teacherId: json['teacherId'] ?? '',
      section: json['section'] ?? '',
      room: json['room'] ?? '',
      schedule: (json['schedule'] as List)
          .map((slot) => ScheduleSlot.fromJson(slot))
          .toList(),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classId': classId,
      'subject': subject,
      'teacherId': teacherId,
      'section': section,
      'room': room,
      'schedule': schedule.map((slot) => slot.toJson()).toList(),
      'description': description,
    };
  }
}

class ScheduleSlot {
  final int dayOfWeek; // 1 = Monday, 7 = Sunday
  final int startHour;
  final int startMinute;
  final int durationMinutes;

  ScheduleSlot({
    required this.dayOfWeek,
    required this.startHour,
    required this.startMinute,
    required this.durationMinutes,
  });

  factory ScheduleSlot.fromJson(Map<String, dynamic> json) {
    return ScheduleSlot(
      dayOfWeek: json['dayOfWeek'] ?? 1,
      startHour: json['startHour'] ?? 9,
      startMinute: json['startMinute'] ?? 0,
      durationMinutes: json['durationMinutes'] ?? 60,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'startHour': startHour,
      'startMinute': startMinute,
      'durationMinutes': durationMinutes,
    };
  }

  DateTime get startTime {
    final now = DateTime.now();
    final daysFromMonday = now.weekday - 1;
    final targetDay = (dayOfWeek - 1 - daysFromMonday) % 7;
    return DateTime(now.year, now.month, now.day + targetDay, startHour, startMinute);
  }

  DateTime get endTime {
    return startTime.add(Duration(minutes: durationMinutes));
  }

  bool get isToday {
    return DateTime.now().weekday == dayOfWeek;
  }

  bool get isNow {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }
}
