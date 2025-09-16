class ClassModel {
  final String id;
  final String name;
  final String section;
  final String grade;
  final String teacherId;
  final String teacherName;
  final List<String> studentIds;
  final List<String> subjects;
  final String academicYear;
  final int capacity;
  final bool isActive;
  final DateTime createdAt;

  ClassModel({
    required this.id,
    required this.name,
    required this.section,
    required this.grade,
    required this.teacherId,
    required this.teacherName,
    this.studentIds = const [],
    this.subjects = const [],
    required this.academicYear,
    this.capacity = 30,
    this.isActive = true,
    required this.createdAt,
  });

  String get fullName => '$grade-$section';

  ClassModel copyWith({
    String? id,
    String? name,
    String? section,
    String? grade,
    String? teacherId,
    String? teacherName,
    List<String>? studentIds,
    List<String>? subjects,
    String? academicYear,
    int? capacity,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ClassModel(
      id: id ?? this.id,
      name: name ?? this.name,
      section: section ?? this.section,
      grade: grade ?? this.grade,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      studentIds: studentIds ?? this.studentIds,
      subjects: subjects ?? this.subjects,
      academicYear: academicYear ?? this.academicYear,
      capacity: capacity ?? this.capacity,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'section': section,
      'grade': grade,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'studentIds': studentIds,
      'subjects': subjects,
      'academicYear': academicYear,
      'capacity': capacity,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'],
      name: json['name'],
      section: json['section'],
      grade: json['grade'],
      teacherId: json['teacherId'],
      teacherName: json['teacherName'],
      studentIds: List<String>.from(json['studentIds'] ?? []),
      subjects: List<String>.from(json['subjects'] ?? []),
      academicYear: json['academicYear'],
      capacity: json['capacity'] ?? 30,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
