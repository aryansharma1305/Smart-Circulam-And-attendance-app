class Teacher {
  final String id;
  final String name;
  final String email;
  final String department;
  final String phoneNumber;
  final List<String> assignedClasses;
  final List<String> subjects;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLogin;

  Teacher({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.phoneNumber,
    this.assignedClasses = const [],
    this.subjects = const [],
    this.isActive = true,
    required this.createdAt,
    this.lastLogin,
  });

  Teacher copyWith({
    String? id,
    String? name,
    String? email,
    String? department,
    String? phoneNumber,
    List<String>? assignedClasses,
    List<String>? subjects,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return Teacher(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      department: department ?? this.department,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      assignedClasses: assignedClasses ?? this.assignedClasses,
      subjects: subjects ?? this.subjects,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'department': department,
      'phoneNumber': phoneNumber,
      'assignedClasses': assignedClasses,
      'subjects': subjects,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      department: json['department'],
      phoneNumber: json['phoneNumber'],
      assignedClasses: List<String>.from(json['assignedClasses'] ?? []),
      subjects: List<String>.from(json['subjects'] ?? []),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'])
          : null,
    );
  }
}
