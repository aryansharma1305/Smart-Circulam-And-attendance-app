/// Domain model for an announcement sent by a teacher to a course/section.
///
/// This is the canonical version; the inline class that previously lived
/// inside `announce_page.dart` has been removed in favour of this model.
class Announcement {
  const Announcement({
    required this.id,
    this.institutionId = '',
    required this.course,
    required this.section,
    required this.title,
    required this.message,
    required this.sentAt,
    required this.senderId,
    required this.senderName,
    this.isScheduled = false,
    this.attachment,
    this.readBy = const [],
  });

  final String id;
  final String institutionId;
  final String course;
  final String section;
  final String title;
  final String message;
  final DateTime sentAt;
  final String senderId;
  final String senderName;
  final bool isScheduled;

  /// URL or local file path of an attachment, if any.
  final String? attachment;

  /// UIDs of users who have read this announcement.
  final List<String> readBy;

  // -------------------------------------------------------------------------
  // Serialisation
  // -------------------------------------------------------------------------

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as String? ?? '',
      institutionId: json['institutionId'] as String? ?? '',
      course: json['course'] as String? ?? '',
      section: json['section'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      sentAt: DateTime.parse(
        json['sentAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      senderId: json['senderId'] as String? ?? '',
      senderName: json['senderName'] as String? ?? '',
      isScheduled: json['isScheduled'] as bool? ?? false,
      attachment: json['attachment'] as String?,
      readBy: List<String>.from(json['readBy'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'institutionId': institutionId,
      'course': course,
      'section': section,
      'title': title,
      'message': message,
      'sentAt': sentAt.toIso8601String(),
      'senderId': senderId,
      'senderName': senderName,
      'isScheduled': isScheduled,
      'attachment': attachment,
      'readBy': readBy,
    };
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  bool hasBeenReadBy(String userId) => readBy.contains(userId);

  bool get hasAttachment => attachment != null && attachment!.isNotEmpty;

  Announcement copyWith({
    String? id,
    String? institutionId,
    String? course,
    String? section,
    String? title,
    String? message,
    DateTime? sentAt,
    String? senderId,
    String? senderName,
    bool? isScheduled,
    String? attachment,
    List<String>? readBy,
  }) {
    return Announcement(
      id: id ?? this.id,
      institutionId: institutionId ?? this.institutionId,
      course: course ?? this.course,
      section: section ?? this.section,
      title: title ?? this.title,
      message: message ?? this.message,
      sentAt: sentAt ?? this.sentAt,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      isScheduled: isScheduled ?? this.isScheduled,
      attachment: attachment ?? this.attachment,
      readBy: readBy ?? this.readBy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Announcement &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Announcement(id: $id, course: $course, title: $title)';
}
