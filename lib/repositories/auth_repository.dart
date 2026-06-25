import '../models/user.dart';
import '../core/app_error.dart';

/// Contract for all authentication operations.
///
/// Implementations must throw [AppError] subtypes on failure:
/// - [AuthorizationError] for invalid credentials or insufficient permissions.
/// - [ValidationError]    for malformed inputs (e.g. empty email).
/// - [NetworkError]       for connectivity failures.
abstract class AuthRepository {
  /// Returns the signed-in [User] or null if no session exists.
  Future<User?> getCurrentUser();

  /// A stream that notifies when the authentication state changes.
  Stream<User?> get authStateChanges;

  /// Signs in with [email] / [password].
  ///
  /// Throws [AuthorizationError] if credentials are invalid.
  Future<User> signIn(String email, String password);

  /// Signs in via a phone [otp] (6-digit code).
  ///
  /// Throws [AuthorizationError] if the OTP is incorrect or expired.
  Future<User> signInWithOtp(String phone, String otp);

  /// Signs in as a specific [role] using email/password credentials.
  ///
  /// Throws [AuthorizationError] if the account's stored role does not match
  /// the requested [role].
  Future<User> signInAsRole(
    UserRole role,
    String email,
    String password,
  );

  /// Ends the current session and clears all cached credentials.
  Future<void> signOut();

  /// Sends a password reset email to [email].
  Future<void> sendPasswordReset(String email);

  /// Updates mutable profile fields for the currently signed-in user.
  ///
  /// Only non-null parameters are changed.
  Future<User> updateProfile({
    String? name,
    String? photoUrl,
    String? phone,
    String? department,
    String? year,
    String? section,
  });
}
