class Course {
  final String id;
  final String code;
  final String name;
  final String teacherId;
  final String department;
  final String semester;
  final List<String> sections;
  final int credits;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Course({
    required this.id,
    required this.code,
    required this.name,
    required this.teacherId,
    required this.department,
    required this.semester,
    required this.sections,
    required this.credits,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] ?? '',
      code: map['code'] ?? '',
      name: map['name'] ?? '',
      teacherId: map['teacher_id'] ?? '',
      department: map['department'] ?? '',
      semester: map['semester'] ?? '',
      sections: List<String>.from(map['sections'] ?? []),
      credits: map['credits'] ?? 0,
      description: map['description'] ?? '',
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'teacher_id': teacherId,
      'department': department,
      'semester': semester,
      'sections': sections,
      'credits': credits,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Course copyWith({
    String? id,
    String? code,
    String? name,
    String? teacherId,
    String? department,
    String? semester,
    List<String>? sections,
    int? credits,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Course(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      teacherId: teacherId ?? this.teacherId,
      department: department ?? this.department,
      semester: semester ?? this.semester,
      sections: sections ?? this.sections,
      credits: credits ?? this.credits,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

