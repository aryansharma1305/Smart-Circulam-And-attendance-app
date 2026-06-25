import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../core/app_error.dart';
import '../../models/user.dart';
import '../auth_repository.dart';

/// Firebase implementation of [AuthRepository].
///
/// Roles are stored exclusively as **custom claims** on the Firebase Auth
/// token (`idTokenResult.claims['role']`).  The client never writes the role
/// field; only the `setUserRole` Cloud Function can do so.
///
/// Profile data (name, phone, department, …) is stored in Firestore
/// `/users/{uid}` and merged with the token claims to produce a [User].
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    required fb.FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  // ── Internal helpers ────────────────────────────────────────────────────

  /// Builds a [User] from the Firebase user's ID-token claims + Firestore doc.
  Future<User> _buildUser(fb.User firebaseUser) async {
    // Force-refresh token to get latest custom claims after role assignment.
    final tokenResult = await firebaseUser.getIdTokenResult(false);
    final roleStr = tokenResult.claims?['role'] as String? ?? 'student';
    final role = UserRole.values.firstWhere(
      (r) => r.name == roleStr,
      orElse: () => UserRole.student,
    );

    // Read mutable profile fields from Firestore.
    final doc = await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();
    final data = doc.data() ?? {};

    return User(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: data['name'] as String? ?? firebaseUser.displayName ?? '',
      phone: data['phone'] as String? ?? firebaseUser.phoneNumber ?? '',
      role: role,
      department: data['department'] as String?,
      year: data['year'] as String?,
      section: data['section'] as String?,
      photoUrl: data['photoUrl'] as String? ?? firebaseUser.photoURL,
      subjects: List<String>.from(data['subjects'] ?? []),
      institutionCode: data['institutionCode'] as String?,
      institutionId: tokenResult.claims?['institutionId'] as String?,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      lastActive: DateTime.now(),
    );
  }

  /// Maps a [fb.FirebaseAuthException] to the appropriate [AppError] subtype.
  AppError _mapAuthException(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return const AuthorizationError(detail: 'Invalid email or password.');
      case 'user-disabled':
        return const AuthorizationError(
          detail: 'This account has been disabled.',
        );
      case 'too-many-requests':
        return const AuthorizationError(
          detail: 'Too many failed attempts. Please try again later.',
        );
      case 'invalid-email':
        return const ValidationError(
          fields: {'email': 'Invalid email address.'},
        );
      case 'network-request-failed':
        return const NetworkError();
      default:
        return NetworkError(detail: e.message ?? e.code);
    }
  }

  // ── AuthRepository interface ────────────────────────────────────────────

  @override
  Future<User?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return _buildUser(firebaseUser);
  }

  @override
  Stream<User?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return _buildUser(firebaseUser);
    });
  }

  @override
  Future<User> signIn(String email, String password) async {
    _validateEmailPassword(email, password);
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      // Force-refresh after sign-in to pull latest custom claims.
      await cred.user!.getIdTokenResult(true);
      return _buildUser(cred.user!);
    } on fb.FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw NetworkError(detail: e.toString());
    }
  }

  @override
  Future<User> signInWithOtp(String phone, String otp) async {
    // Phone OTP is deferred to Phase 4.
    throw const ServiceUnavailableError(
      detail: 'Phone OTP sign-in is not yet available.',
    );
  }

  @override
  Future<User> signInAsRole(
    UserRole role,
    String email,
    String password,
  ) async {
    final user = await signIn(email, password);
    if (user.role != role) {
      await _auth.signOut();
      throw AuthorizationError(
        detail: 'This account does not have the ${role.name} role.',
      );
    }
    return user;
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw NetworkError(detail: e.toString());
    }
  }

  @override
  Future<User> updateProfile({
    String? name,
    String? photoUrl,
    String? phone,
    String? department,
    String? year,
    String? section,
  }) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      throw const AuthorizationError(detail: 'Not signed in.');
    }

    // Build update map — only include non-null fields.
    final updates = <String, dynamic>{
      if (name != null) 'name': name,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (phone != null) 'phone': phone,
      if (department != null) 'department': department,
      if (year != null) 'year': year,
      if (section != null) 'section': section,
      'lastActive': FieldValue.serverTimestamp(),
    };

    // NOTE: 'role' is intentionally omitted — it must come from custom claims.
    await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .set(updates, SetOptions(merge: true));

    // Also update Firebase Auth display name / photo if provided.
    if (name != null || photoUrl != null) {
      await firebaseUser.updateDisplayName(name);
      if (photoUrl != null) await firebaseUser.updatePhotoURL(photoUrl);
    }

    return _buildUser(firebaseUser);
  }

  /// Sends a password reset email to [email].
  @override
  Future<void> sendPasswordReset(String email) async {
    if (email.trim().isEmpty) {
      throw const ValidationError(fields: {'email': 'Email is required.'});
    }
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on fb.FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  // ── Private validation ──────────────────────────────────────────────────

  void _validateEmailPassword(String email, String password) {
    final errors = <String, String>{};
    if (email.trim().isEmpty) errors['email'] = 'Email is required.';
    if (password.isEmpty) errors['password'] = 'Password is required.';
    if (errors.isNotEmpty) throw ValidationError(fields: errors);
  }
}
