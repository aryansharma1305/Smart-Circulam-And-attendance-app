import '../../models/announcement.dart';
import '../../models/user.dart';
import '../../core/app_error.dart';
import '../announcement_repository.dart';

/// In-memory [AnnouncementRepository].
///
/// Seeds the same 2 sample announcements that previously lived in
/// [AnnouncePage._loadMockData()].
class InMemoryAnnouncementRepository implements AnnouncementRepository {
  InMemoryAnnouncementRepository() {
    _seed();
  }

  final List<Announcement> _announcements = [];
  int _nextId = 100;

  // -------------------------------------------------------------------------
  // Seed
  // -------------------------------------------------------------------------

  void _seed() {
    final now = DateTime.now();

    _announcements.addAll([
      Announcement(
        id: '1',
        course: 'DSA',
        section: 'Sec A',
        title: 'Assignment 3 Submission',
        message:
            'Please submit Assignment 3 by Friday. '
            'Late submissions will not be accepted.',
        sentAt: now.subtract(const Duration(hours: 2)),
        senderId: 'teacher-001',
        senderName: 'Prof. Sarah Williams',
        attachment: 'assignment3.pdf',
      ),
      Announcement(
        id: '2',
        course: 'DBMS',
        section: 'Sec B',
        title: 'Mid-term Exam Schedule',
        message:
            'Mid-term exam will be held on March 15th. '
            'Please bring your student ID.',
        sentAt: now.subtract(const Duration(days: 1)),
        senderId: 'teacher-001',
        senderName: 'Prof. Sarah Williams',
        isScheduled: true,
      ),
    ]);
  }

  // -------------------------------------------------------------------------
  // AnnouncementRepository implementation
  // -------------------------------------------------------------------------

  @override
  Future<List<Announcement>> getAnnouncementsForUser(
    String userId,
    UserRole role,
    String institutionId,
  ) async {
    if (role == UserRole.teacher) {
      // Teachers see announcements they created
      return _announcements.where((a) => a.senderId == userId).toList()
        ..sort((a, b) => b.sentAt.compareTo(a.sentAt));
    }

    // Students see all announcements (Phase 3: filter by enrolled courses)
    return List.of(_announcements)
      ..sort((a, b) => b.sentAt.compareTo(a.sentAt));
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    return _announcements.where((a) => !a.hasBeenReadBy(userId)).length;
  }

  @override
  Future<Announcement> createAnnouncement(Announcement announcement) async {
    final saved = announcement.copyWith(id: '${_nextId++}');
    _announcements.add(saved);
    return saved;
  }

  @override
  Future<void> markRead(String announcementId, String userId) async {
    final index = _announcements.indexWhere((a) => a.id == announcementId);
    if (index == -1) return; // idempotent: ignore unknown IDs

    final existing = _announcements[index];
    if (!existing.hasBeenReadBy(userId)) {
      _announcements[index] = existing.copyWith(
        readBy: [...existing.readBy, userId],
      );
    }
  }

  @override
  Future<void> deleteAnnouncement(String announcementId) async {
    _announcements.removeWhere((a) => a.id == announcementId);
  }

  // -------------------------------------------------------------------------
  // Test helpers
  // -------------------------------------------------------------------------

  void reset() {
    _announcements.clear();
    _nextId = 100;
    _seed();
  }

  List<Announcement> get allAnnouncements => List.unmodifiable(_announcements);
}
