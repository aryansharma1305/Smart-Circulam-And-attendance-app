enum UserRole { admin, teacher, student, parent, counselor }

class User {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final UserRole role;
  final String? department;
  final String? year;
  final String? section;
  final String? photoUrl;
  final List<String>
  subjects; // For teachers: subjects taught, for students: subjects enrolled
  final String? parentId; // For students: link to parent account
  final List<String> interests;
  final List<String> strengths;
  final List<String> goals;
  final Map<String, dynamic> privacy;
  final String? deviceHash;
  final String? institutionCode;
  final String? institutionId;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime lastActive;

  User({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    this.department,
    this.year,
    this.section,
    this.photoUrl,
    this.subjects = const [],
    this.parentId,
    this.interests = const [],
    this.strengths = const [],
    this.goals = const [],
    this.privacy = const {},
    this.deviceHash,
    this.institutionCode,
    this.institutionId,
    this.preferences = const {},
    required this.createdAt,
    required this.lastActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => UserRole.student,
      ),
      department: json['department'],
      year: json['year'],
      section: json['section'],
      photoUrl: json['photoUrl'],
      subjects: List<String>.from(json['subjects'] ?? []),
      parentId: json['parentId'],
      interests: List<String>.from(json['interests'] ?? []),
      strengths: List<String>.from(json['strengths'] ?? []),
      goals: List<String>.from(json['goals'] ?? []),
      privacy: Map<String, dynamic>.from(json['privacy'] ?? {}),
      deviceHash: json['deviceHash'],
      institutionCode: json['institutionCode'],
      institutionId: json['institutionId'],
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      lastActive: DateTime.parse(json['lastActive']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role.toString().split('.').last,
      'department': department,
      'year': year,
      'section': section,
      'photoUrl': photoUrl,
      'subjects': subjects,
      'parentId': parentId,
      'interests': interests,
      'strengths': strengths,
      'goals': goals,
      'privacy': privacy,
      'deviceHash': deviceHash,
      'institutionCode': institutionCode,
      'institutionId': institutionId,
      'preferences': preferences,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
    };
  }

  User copyWith({
    String? name,
    String? phone,
    String? email,
    UserRole? role,
    String? department,
    String? year,
    String? section,
    String? photoUrl,
    List<String>? subjects,
    String? parentId,
    List<String>? interests,
    List<String>? strengths,
    List<String>? goals,
    Map<String, dynamic>? privacy,
    String? deviceHash,
    String? institutionCode,
    String? institutionId,
    Map<String, dynamic>? preferences,
    DateTime? lastActive,
  }) {
    return User(
      uid: uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      department: department ?? this.department,
      year: year ?? this.year,
      section: section ?? this.section,
      photoUrl: photoUrl ?? this.photoUrl,
      subjects: subjects ?? this.subjects,
      parentId: parentId ?? this.parentId,
      interests: interests ?? this.interests,
      strengths: strengths ?? this.strengths,
      goals: goals ?? this.goals,
      privacy: privacy ?? this.privacy,
      deviceHash: deviceHash ?? this.deviceHash,
      institutionCode: institutionCode ?? this.institutionCode,
      institutionId: institutionId ?? this.institutionId,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  bool get isStudent => role == UserRole.student;
  bool get isTeacher => role == UserRole.teacher;
  bool get isAdmin => role == UserRole.admin;
  bool get isParent => role == UserRole.parent;
  bool get isCounselor => role == UserRole.counselor;

  String get roleDisplayName {
    switch (role) {
      case UserRole.student:
        return 'Student';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.admin:
        return 'Admin';
      case UserRole.parent:
        return 'Parent';
      case UserRole.counselor:
        return 'Counselor';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && uid == other.uid;

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() => 'User(uid: $uid, name: $name, role: ${role.name})';
}
