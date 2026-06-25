enum InAppNotificationType {
  attendance,
  announcement,
  exception,
  classUpdate,
  goal,
  system,
}

class InAppNotification {
  const InAppNotification({
    required this.id,
    required this.institutionId,
    required this.recipientId,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.readAt,
    this.actionRoute,
    this.referenceType,
    this.referenceId,
    this.metadata = const {},
  });

  final String id;
  final String institutionId;
  final String recipientId;
  final String title;
  final String message;
  final InAppNotificationType type;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? actionRoute;
  final String? referenceType;
  final String? referenceId;
  final Map<String, dynamic> metadata;

  bool get isRead => readAt != null;

  factory InAppNotification.fromMap(Map<String, dynamic> map) {
    return InAppNotification(
      id: map['id'] ?? '',
      institutionId: map['institutionId'] ?? '',
      recipientId: map['recipientId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: InAppNotificationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => InAppNotificationType.system,
      ),
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      readAt: map['readAt'] != null ? DateTime.parse(map['readAt']) : null,
      actionRoute: map['actionRoute'],
      referenceType: map['referenceType'],
      referenceId: map['referenceId'],
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'institutionId': institutionId,
      'recipientId': recipientId,
      'title': title,
      'message': message,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'actionRoute': actionRoute,
      'referenceType': referenceType,
      'referenceId': referenceId,
      'metadata': metadata,
    };
  }

  InAppNotification copyWith({
    String? id,
    String? institutionId,
    String? recipientId,
    String? title,
    String? message,
    InAppNotificationType? type,
    DateTime? createdAt,
    DateTime? readAt,
    String? actionRoute,
    String? referenceType,
    String? referenceId,
    Map<String, dynamic>? metadata,
  }) {
    return InAppNotification(
      id: id ?? this.id,
      institutionId: institutionId ?? this.institutionId,
      recipientId: recipientId ?? this.recipientId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      actionRoute: actionRoute ?? this.actionRoute,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      metadata: metadata ?? this.metadata,
    );
  }
}
