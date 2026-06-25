enum RecordStatus { active, inactive, archived }

DateTime _date(dynamic value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.parse(value);
  try {
    return (value as dynamic).toDate() as DateTime;
  } catch (_) {
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}

abstract class AcademicRecord {
  const AcademicRecord({
    required this.id,
    required this.institutionId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String institutionId;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class Department extends AcademicRecord {
  const Department({
    required super.id,
    required super.institutionId,
    required this.code,
    required this.name,
    required this.status,
    required super.createdAt,
    required super.updatedAt,
  });

  final String code;
  final String name;
  final RecordStatus status;

  factory Department.fromJson(Map<String, dynamic> json) => Department(
    id: json['id'] ?? '',
    institutionId: json['institutionId'] ?? '',
    code: json['code'] ?? '',
    name: json['name'] ?? '',
    status: RecordStatus.values.byName(json['status'] ?? 'active'),
    createdAt: _date(json['createdAt']),
    updatedAt: _date(json['updatedAt']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'institutionId': institutionId,
    'code': code,
    'name': name,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

class AcademicTerm extends AcademicRecord {
  const AcademicTerm({
    required super.id,
    required super.institutionId,
    required this.name,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    required super.createdAt,
    required super.updatedAt,
  });

  final String name;
  final DateTime startsAt;
  final DateTime endsAt;
  final RecordStatus status;

  factory AcademicTerm.fromJson(Map<String, dynamic> json) => AcademicTerm(
    id: json['id'] ?? '',
    institutionId: json['institutionId'] ?? '',
    name: json['name'] ?? '',
    startsAt: _date(json['startsAt']),
    endsAt: _date(json['endsAt']),
    status: RecordStatus.values.byName(json['status'] ?? 'active'),
    createdAt: _date(json['createdAt']),
    updatedAt: _date(json['updatedAt']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'institutionId': institutionId,
    'name': name,
    'startsAt': startsAt.toIso8601String(),
    'endsAt': endsAt.toIso8601String(),
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

class Subject extends AcademicRecord {
  const Subject({
    required super.id,
    required super.institutionId,
    required this.departmentId,
    required this.code,
    required this.name,
    required this.creditHours,
    required this.status,
    required super.createdAt,
    required super.updatedAt,
  });

  final String departmentId;
  final String code;
  final String name;
  final int creditHours;
  final RecordStatus status;

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
    id: json['id'] ?? '',
    institutionId: json['institutionId'] ?? '',
    departmentId: json['departmentId'] ?? '',
    code: json['code'] ?? '',
    name: json['name'] ?? '',
    creditHours: json['creditHours'] ?? 0,
    status: RecordStatus.values.byName(json['status'] ?? 'active'),
    createdAt: _date(json['createdAt']),
    updatedAt: _date(json['updatedAt']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'institutionId': institutionId,
    'departmentId': departmentId,
    'code': code,
    'name': name,
    'creditHours': creditHours,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

class AcademicSection extends AcademicRecord {
  const AcademicSection({
    required super.id,
    required super.institutionId,
    required this.courseId,
    required this.termId,
    required this.name,
    required this.year,
    required this.status,
    required super.createdAt,
    required super.updatedAt,
  });

  final String courseId;
  final String termId;
  final String name;
  final int year;
  final RecordStatus status;

  factory AcademicSection.fromJson(Map<String, dynamic> json) =>
      AcademicSection(
        id: json['id'] ?? '',
        institutionId: json['institutionId'] ?? '',
        courseId: json['courseId'] ?? '',
        termId: json['termId'] ?? '',
        name: json['name'] ?? '',
        year: json['year'] ?? 1,
        status: RecordStatus.values.byName(json['status'] ?? 'active'),
        createdAt: _date(json['createdAt']),
        updatedAt: _date(json['updatedAt']),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'institutionId': institutionId,
    'courseId': courseId,
    'termId': termId,
    'name': name,
    'year': year,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

class AcademicRoom extends AcademicRecord {
  const AcademicRoom({
    required super.id,
    required super.institutionId,
    required this.code,
    required this.building,
    required this.capacity,
    required this.status,
    required super.createdAt,
    required super.updatedAt,
  });

  final String code;
  final String building;
  final int capacity;
  final RecordStatus status;

  factory AcademicRoom.fromJson(Map<String, dynamic> json) => AcademicRoom(
    id: json['id'] ?? '',
    institutionId: json['institutionId'] ?? '',
    code: json['code'] ?? '',
    building: json['building'] ?? '',
    capacity: json['capacity'] ?? 0,
    status: RecordStatus.values.byName(json['status'] ?? 'active'),
    createdAt: _date(json['createdAt']),
    updatedAt: _date(json['updatedAt']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'institutionId': institutionId,
    'code': code,
    'building': building,
    'capacity': capacity,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

class Enrollment extends AcademicRecord {
  const Enrollment({
    required super.id,
    required super.institutionId,
    required this.studentId,
    required this.sectionId,
    required this.subjectId,
    required this.termId,
    required this.status,
    required super.createdAt,
    required super.updatedAt,
  });

  final String studentId;
  final String sectionId;
  final String subjectId;
  final String termId;
  final RecordStatus status;

  String get logicalKey => '$studentId|$sectionId|$subjectId|$termId';

  factory Enrollment.fromJson(Map<String, dynamic> json) => Enrollment(
    id: json['id'] ?? '',
    institutionId: json['institutionId'] ?? '',
    studentId: json['studentId'] ?? '',
    sectionId: json['sectionId'] ?? '',
    subjectId: json['subjectId'] ?? '',
    termId: json['termId'] ?? '',
    status: RecordStatus.values.byName(json['status'] ?? 'active'),
    createdAt: _date(json['createdAt']),
    updatedAt: _date(json['updatedAt']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'institutionId': institutionId,
    'studentId': studentId,
    'sectionId': sectionId,
    'subjectId': subjectId,
    'termId': termId,
    'status': status.name,
    'logicalKey': logicalKey,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

class TeachingAssignment extends AcademicRecord {
  const TeachingAssignment({
    required super.id,
    required super.institutionId,
    required this.teacherId,
    required this.sectionId,
    required this.subjectId,
    required this.termId,
    required super.createdAt,
    required super.updatedAt,
  });

  final String teacherId;
  final String sectionId;
  final String subjectId;
  final String termId;

  factory TeachingAssignment.fromJson(Map<String, dynamic> json) =>
      TeachingAssignment(
        id: json['id'] ?? '',
        institutionId: json['institutionId'] ?? '',
        teacherId: json['teacherId'] ?? '',
        sectionId: json['sectionId'] ?? '',
        subjectId: json['subjectId'] ?? '',
        termId: json['termId'] ?? '',
        createdAt: _date(json['createdAt']),
        updatedAt: _date(json['updatedAt']),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'institutionId': institutionId,
    'teacherId': teacherId,
    'sectionId': sectionId,
    'subjectId': subjectId,
    'termId': termId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

class AcademicTimetableSlot extends AcademicRecord {
  const AcademicTimetableSlot({
    required super.id,
    required super.institutionId,
    required this.termId,
    required this.sectionId,
    required this.subjectId,
    required this.teacherId,
    required this.roomId,
    required this.weekday,
    required this.startMinute,
    required this.endMinute,
    required this.status,
    required super.createdAt,
    required super.updatedAt,
  });

  final String termId;
  final String sectionId;
  final String subjectId;
  final String teacherId;
  final String roomId;
  final int weekday;
  final int startMinute;
  final int endMinute;
  final RecordStatus status;

  bool overlaps(AcademicTimetableSlot other) =>
      weekday == other.weekday &&
      startMinute < other.endMinute &&
      other.startMinute < endMinute;

  factory AcademicTimetableSlot.fromJson(Map<String, dynamic> json) =>
      AcademicTimetableSlot(
        id: json['id'] ?? '',
        institutionId: json['institutionId'] ?? '',
        termId: json['termId'] ?? '',
        sectionId: json['sectionId'] ?? '',
        subjectId: json['subjectId'] ?? '',
        teacherId: json['teacherId'] ?? '',
        roomId: json['roomId'] ?? '',
        weekday: json['weekday'] ?? 1,
        startMinute: json['startMinute'] ?? 0,
        endMinute: json['endMinute'] ?? 0,
        status: RecordStatus.values.byName(json['status'] ?? 'active'),
        createdAt: _date(json['createdAt']),
        updatedAt: _date(json['updatedAt']),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'institutionId': institutionId,
    'termId': termId,
    'sectionId': sectionId,
    'subjectId': subjectId,
    'teacherId': teacherId,
    'roomId': roomId,
    'weekday': weekday,
    'startMinute': startMinute,
    'endMinute': endMinute,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

class AcademicCatalog {
  const AcademicCatalog({
    this.departments = const [],
    this.terms = const [],
    this.subjects = const [],
    this.sections = const [],
    this.rooms = const [],
    this.enrollments = const [],
    this.assignments = const [],
    this.timetable = const [],
  });

  final List<Department> departments;
  final List<AcademicTerm> terms;
  final List<Subject> subjects;
  final List<AcademicSection> sections;
  final List<AcademicRoom> rooms;
  final List<Enrollment> enrollments;
  final List<TeachingAssignment> assignments;
  final List<AcademicTimetableSlot> timetable;
}
