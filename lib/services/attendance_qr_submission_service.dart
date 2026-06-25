import '../core/app_error.dart';
import '../models/attendance.dart';
import '../models/session.dart';
import '../repositories/attendance_repository.dart';
import 'secure_qr_service.dart';

typedef SessionResolver = Future<Session?> Function(String sessionId);
typedef EnrollmentVerifier =
    Future<bool> Function({
      required String sessionId,
      required String studentId,
    });

class AttendanceQrSubmissionService {
  AttendanceQrSubmissionService({
    required SecureQrService qrService,
    required AttendanceRepository attendanceRepository,
    required SessionResolver resolveSession,
    required EnrollmentVerifier isStudentEnrolled,
    DateTime Function()? now,
  }) : _qrService = qrService,
       _attendanceRepository = attendanceRepository,
       _resolveSession = resolveSession,
       _isStudentEnrolled = isStudentEnrolled,
       _now = now ?? DateTime.now;

  final SecureQrService _qrService;
  final AttendanceRepository _attendanceRepository;
  final SessionResolver _resolveSession;
  final EnrollmentVerifier _isStudentEnrolled;
  final DateTime Function() _now;

  Future<Attendance> submit({
    required String rawQrToken,
    required String studentId,
    String? expectedSessionId,
    String? deviceHash,
    bool geoOK = false,
    bool ssidOK = false,
  }) async {
    final validation = _qrService.verifyToken(
      rawToken: rawQrToken,
      expectedSessionId: expectedSessionId,
      now: _now(),
    );
    if (!validation.isValid || validation.token == null) {
      throw ValidationError(
        fields: {'qr': validation.error ?? 'Invalid QR token.'},
      );
    }

    final token = validation.token!;
    final session = await _resolveSession(token.sessionId);
    if (session == null) {
      throw const ValidationError(
        fields: {'session': 'Attendance session was not found.'},
      );
    }
    if (!session.isLive) {
      throw const ConflictError(detail: 'Attendance session is not live.');
    }

    final enrolled = await _isStudentEnrolled(
      sessionId: token.sessionId,
      studentId: studentId,
    );
    if (!enrolled) {
      throw const AuthorizationError(
        detail: 'You are not enrolled in this attendance session.',
      );
    }

    return _attendanceRepository.markAttendance(
      Attendance(
        sessionId: token.sessionId,
        studentId: studentId,
        status: AttendanceStatus.present,
        deviceHash: deviceHash,
        geoOK: geoOK,
        ssidOK: ssidOK,
        totpNonce: token.nonce,
        createdAt: _now(),
      ),
    );
  }
}
