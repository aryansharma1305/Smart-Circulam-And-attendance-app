/// Sealed base class for all application-level errors.
///
/// Use this instead of raw [Exception] or [String] so that UI layers
/// can switch exhaustively on the error kind and display appropriate
/// messages without inspecting string content.
sealed class AppError implements Exception {
  const AppError();

  /// Human-readable message suitable for display in a snackbar or dialog.
  String get message;

  /// Short machine-readable code (e.g. 'unauthorized', 'duplicate_session').
  String get code;

  @override
  String toString() => '$runtimeType(code: $code, message: $message)';
}

// ---------------------------------------------------------------------------
// Subtypes
// ---------------------------------------------------------------------------

/// The current user does not have permission to perform the requested action.
///
/// Examples: accessing a teacher-only route as a student, or calling an
/// endpoint before signing in.
class AuthorizationError extends AppError {
  const AuthorizationError({this.detail});

  final String? detail;

  @override
  String get code => 'unauthorized';

  @override
  String get message =>
      detail ?? 'You are not authorised to perform this action.';
}

/// One or more fields failed validation before reaching the repository.
///
/// [fields] maps field names to their specific error messages, e.g.
/// `{'email': 'Invalid email address', 'password': 'Too short'}`.
class ValidationError extends AppError {
  const ValidationError({required this.fields, String? summary})
      : _summary = summary;

  final Map<String, String> fields;
  final String? _summary;

  @override
  String get code => 'validation_error';

  @override
  String get message =>
      _summary ??
      fields.entries.map((e) => '${e.key}: ${e.value}').join('; ');
}

/// A network-level failure (timeout, no connectivity, DNS error, etc.).
class NetworkError extends AppError {
  const NetworkError({this.detail});

  final String? detail;

  @override
  String get code => 'network_error';

  @override
  String get message =>
      detail ?? 'A network error occurred. Please check your connection.';
}

/// The requested operation conflicts with existing data.
///
/// Examples: marking attendance twice in the same session, creating a session
/// that overlaps an existing live session.
class ConflictError extends AppError {
  const ConflictError({required this.detail});

  final String detail;

  @override
  String get code => 'conflict';

  @override
  String get message => detail;
}

/// The underlying service (e.g. Firestore, a feature flag) is not available.
///
/// Used when the app is offline and the operation cannot be queued, or when
/// a feature is disabled for this institution.
class ServiceUnavailableError extends AppError {
  const ServiceUnavailableError({this.detail});

  final String? detail;

  @override
  String get code => 'service_unavailable';

  @override
  String get message =>
      detail ?? 'The service is temporarily unavailable. Please try again later.';
}
