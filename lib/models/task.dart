enum TaskType { reading, coding, quiz, project, exercise, summary, other }
enum TaskDifficulty { easy, medium, hard }
enum TaskStatus { pending, inProgress, completed, skipped }

class Task {
  final String id;
  final String title;
  final String description;
  final List<String> tags;
  final int durationMinutes;
  final TaskType type;
  final TaskDifficulty difficulty;
  final Map<String, dynamic> skillMap;
  final String? contentUrl;
  final String? createdBy;
  final bool isActive;
  final String? subject; // optional subject tag
  final DateTime? dueAt; // optional due date
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.durationMinutes,
    required this.type,
    required this.difficulty,
    required this.skillMap,
    this.contentUrl,
    this.createdBy,
    required this.isActive,
    this.subject,
    this.dueAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      durationMinutes: map['duration_minutes'] ?? map['estimatedMinutes'] ?? 0,
      type: TaskType.values.firstWhere(
        (e) => e.toString() == 'TaskType.${map['type']}',
        orElse: () => TaskType.other,
      ),
      difficulty: TaskDifficulty.values.firstWhere(
        (e) => e.toString() == 'TaskDifficulty.${map['difficulty']}',
        orElse: () => TaskDifficulty.medium,
      ),
      skillMap: Map<String, dynamic>.from(map['skill_map'] ?? {}),
      contentUrl: map['content_url'],
      createdBy: map['created_by'],
      isActive: map['is_active'] ?? true,
      subject: map['subject'],
      dueAt: map['dueAt'] != null
          ? DateTime.tryParse(map['dueAt'])
          : (map['due_at'] != null
              ? DateTime.tryParse(map['due_at'])
              : null),
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'tags': tags,
      'duration_minutes': durationMinutes,
      'type': type.toString().split('.').last,
      'difficulty': difficulty.toString().split('.').last,
      'skill_map': skillMap,
      'content_url': contentUrl,
      'created_by': createdBy,
      'is_active': isActive,
      'subject': subject,
      'dueAt': dueAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? tags,
    int? durationMinutes,
    TaskType? type,
    TaskDifficulty? difficulty,
    Map<String, dynamic>? skillMap,
    String? contentUrl,
    String? createdBy,
    bool? isActive,
    String? subject,
    DateTime? dueAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      skillMap: skillMap ?? this.skillMap,
      contentUrl: contentUrl ?? this.contentUrl,
      createdBy: createdBy ?? this.createdBy,
      isActive: isActive ?? this.isActive,
      subject: subject ?? this.subject,
      dueAt: dueAt ?? this.dueAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case TaskType.reading:
        return 'Reading';
      case TaskType.coding:
        return 'Coding';
      case TaskType.quiz:
        return 'Quiz';
      case TaskType.project:
        return 'Project';
      case TaskType.exercise:
        return 'Exercise';
      case TaskType.summary:
        return 'Summary';
      case TaskType.other:
        return 'Other';
    }
  }

  String get difficultyDisplayName {
    switch (difficulty) {
      case TaskDifficulty.easy:
        return 'Easy';
      case TaskDifficulty.medium:
        return 'Medium';
      case TaskDifficulty.hard:
        return 'Hard';
    }
  }

  String get durationDisplay {
    if (durationMinutes < 60) {
      return '${durationMinutes}m';
    } else {
      final hours = durationMinutes ~/ 60;
      final minutes = durationMinutes % 60;
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
  }

  // Backwards-compat fields for services that expect these names
  int get estimatedMinutes => durationMinutes;

  // Simple heuristic value metric for sorting (shorter tasks first, harder tasks higher)
  double get valuePerMinute {
    final difficultyWeight = switch (difficulty) {
      TaskDifficulty.easy => 1.0,
      TaskDifficulty.medium => 1.25,
      TaskDifficulty.hard => 1.5,
    };
    final minutes = durationMinutes == 0 ? 1 : durationMinutes;
    return difficultyWeight / minutes;
  }

  bool matchesDuration(int availableMinutes) {
    return durationMinutes <= availableMinutes;
  }

  bool matchesTags(List<String> userInterests) {
    return tags.any((tag) => userInterests.contains(tag));
  }
}

class TaskRecommendation {
  final String id;
  final String studentId;
  final DateTime date;
  final List<String> taskIds;
  final String rationale;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;

  TaskRecommendation({
    required this.id,
    required this.studentId,
    required this.date,
    required this.taskIds,
    required this.rationale,
    required this.isCompleted,
    this.completedAt,
    required this.createdAt,
  });

  factory TaskRecommendation.fromMap(Map<String, dynamic> map) {
    return TaskRecommendation(
      id: map['id'] ?? '',
      studentId: map['student_id'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      taskIds: List<String>.from(map['task_ids'] ?? []),
      rationale: map['rationale'] ?? '',
      isCompleted: map['is_completed'] ?? false,
      completedAt: map['completed_at'] != null 
          ? DateTime.parse(map['completed_at']) 
          : null,
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'date': date.toIso8601String(),
      'task_ids': taskIds,
      'rationale': rationale,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class StudentTask {
  final String id;
  final String studentId;
  final String taskId;
  final TaskStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int? actualDurationMinutes;
  final String? notes;
  final double? rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudentTask({
    required this.id,
    required this.studentId,
    required this.taskId,
    required this.status,
    this.startedAt,
    this.completedAt,
    this.actualDurationMinutes,
    this.notes,
    this.rating,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudentTask.fromMap(Map<String, dynamic> map) {
    return StudentTask(
      id: map['id'] ?? '',
      studentId: map['student_id'] ?? '',
      taskId: map['task_id'] ?? '',
      status: TaskStatus.values.firstWhere(
        (e) => e.toString() == 'TaskStatus.${map['status']}',
        orElse: () => TaskStatus.pending,
      ),
      startedAt: map['started_at'] != null 
          ? DateTime.parse(map['started_at']) 
          : null,
      completedAt: map['completed_at'] != null 
          ? DateTime.parse(map['completed_at']) 
          : null,
      actualDurationMinutes: map['actual_duration_minutes'],
      notes: map['notes'],
      rating: map['rating']?.toDouble(),
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'task_id': taskId,
      'status': status.toString().split('.').last,
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'actual_duration_minutes': actualDurationMinutes,
      'notes': notes,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isCompleted {
    return status == TaskStatus.completed;
  }

  bool get isInProgress {
    return status == TaskStatus.inProgress;
  }

  bool get isPending {
    return status == TaskStatus.pending;
  }

  bool get isSkipped {
    return status == TaskStatus.skipped;
  }
}