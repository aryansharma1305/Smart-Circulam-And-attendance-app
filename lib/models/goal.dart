enum GoalType { academic, career, personal, skill }

enum GoalStatus { active, completed, paused, cancelled }

enum GoalPriority { low, medium, high }

class Goal {
  final String id;
  final String studentId;
  final String title;
  final String description;
  final GoalType type;
  final GoalStatus status;
  final GoalPriority priority;
  final DateTime targetDate;
  final List<String> tags;
  final Map<String, dynamic> metrics;
  final int progress; // 0-100
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Goal({
    required this.id,
    required this.studentId,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.priority,
    required this.targetDate,
    required this.tags,
    required this.metrics,
    required this.progress,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] ?? '',
      studentId: map['student_id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: GoalType.values.firstWhere(
        (e) => e.toString() == 'GoalType.${map['type']}',
        orElse: () => GoalType.personal,
      ),
      status: GoalStatus.values.firstWhere(
        (e) => e.toString() == 'GoalStatus.${map['status']}',
        orElse: () => GoalStatus.active,
      ),
      priority: GoalPriority.values.firstWhere(
        (e) => e.toString() == 'GoalPriority.${map['priority']}',
        orElse: () => GoalPriority.medium,
      ),
      targetDate: DateTime.parse(
        map['target_date'] ??
            DateTime.now().add(Duration(days: 30)).toIso8601String(),
      ),
      tags: List<String>.from(map['tags'] ?? []),
      metrics: Map<String, dynamic>.from(map['metrics'] ?? {}),
      progress: map['progress'] ?? 0,
      notes: map['notes'],
      createdAt: DateTime.parse(
        map['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'target_date': targetDate.toIso8601String(),
      'tags': tags,
      'metrics': metrics,
      'progress': progress,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Goal copyWith({
    String? id,
    String? studentId,
    String? title,
    String? description,
    GoalType? type,
    GoalStatus? status,
    GoalPriority? priority,
    DateTime? targetDate,
    List<String>? tags,
    Map<String, dynamic>? metrics,
    int? progress,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      targetDate: targetDate ?? this.targetDate,
      tags: tags ?? this.tags,
      metrics: metrics ?? this.metrics,
      progress: progress ?? this.progress,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case GoalType.academic:
        return 'Academic';
      case GoalType.career:
        return 'Career';
      case GoalType.personal:
        return 'Personal';
      case GoalType.skill:
        return 'Skill';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case GoalStatus.active:
        return 'Active';
      case GoalStatus.completed:
        return 'Completed';
      case GoalStatus.paused:
        return 'Paused';
      case GoalStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get priorityDisplayName {
    switch (priority) {
      case GoalPriority.low:
        return 'Low';
      case GoalPriority.medium:
        return 'Medium';
      case GoalPriority.high:
        return 'High';
    }
  }

  bool get isActive {
    return status == GoalStatus.active;
  }

  bool get isCompleted {
    return status == GoalStatus.completed;
  }

  bool get isOverdue {
    return DateTime.now().isAfter(targetDate) && !isCompleted;
  }

  int get daysRemaining {
    final now = DateTime.now();
    final difference = targetDate.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  double get progressDecimal {
    return progress / 100.0;
  }
}

class GoalObjective {
  final String id;
  final String goalId;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime targetDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  GoalObjective({
    required this.id,
    required this.goalId,
    required this.title,
    required this.description,
    required this.isCompleted,
    this.completedAt,
    required this.targetDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GoalObjective.fromMap(Map<String, dynamic> map) {
    return GoalObjective(
      id: map['id'] ?? '',
      goalId: map['goal_id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isCompleted: map['is_completed'] ?? false,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'])
          : null,
      targetDate: DateTime.parse(
        map['target_date'] ??
            DateTime.now().add(Duration(days: 7)).toIso8601String(),
      ),
      createdAt: DateTime.parse(
        map['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goal_id': goalId,
      'title': title,
      'description': description,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'target_date': targetDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  GoalObjective copyWith({
    String? id,
    String? goalId,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? targetDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GoalObjective(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isOverdue {
    return DateTime.now().isAfter(targetDate) && !isCompleted;
  }

  int get daysRemaining {
    final now = DateTime.now();
    final difference = targetDate.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }
}
