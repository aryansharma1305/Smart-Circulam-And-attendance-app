import '../models/announcement.dart';
import '../models/user.dart';
import '../core/app_error.dart';

/// Contract for announcement reads and writes.
///
/// Implementations throw [AppError] subtypes on failure.
abstract class AnnouncementRepository {
  // -------------------------------------------------------------------------
  // Reads
  // -------------------------------------------------------------------------

  /// Returns announcements relevant to [userId] for their [role], ordered by
  /// most-recent first.
  ///
  /// For teachers, this returns announcements they created.
  /// For students, this returns announcements targeted at their
  /// enrolled courses/sections.
  Future<List<Announcement>> getAnnouncementsForUser(
    String userId,
    UserRole role,
    String institutionId,
  );

  /// Returns the count of announcements not yet read by [userId].
  Future<int> getUnreadCount(String userId);

  // -------------------------------------------------------------------------
  // Writes
  // -------------------------------------------------------------------------

  /// Persists a new [announcement] and returns the saved copy (with assigned
  /// [id]).
  Future<Announcement> createAnnouncement(Announcement announcement);

  /// Records that [userId] has read [announcementId].
  ///
  /// Idempotent — calling this multiple times for the same pair is safe.
  Future<void> markRead(String announcementId, String userId);

  /// Deletes an announcement.
  Future<void> deleteAnnouncement(String announcementId);
}
