import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart' as app_user;
import '../core/app_error.dart';
import '../repositories/auth_repository.dart';
import '../providers/repository_providers.dart';

// ---------------------------------------------------------------------------
// Auth Controller
// ---------------------------------------------------------------------------

/// Manages the authentication state for the entire application.
///
/// This replaces the original [AuthNotifier] and delegates all credential
/// operations to the injected [AuthRepository], making the controller
/// fully testable without Firebase.
class AuthController
    extends StateNotifier<AsyncValue<app_user.User?>> {
  AuthController(this._repository) : super(const AsyncValue.loading()) {
    _init();
  }

  final AuthRepository _repository;
  StreamSubscription<app_user.User?>? _subscription;

  void _init() {
    _subscription = _repository.authStateChanges.listen(
      (user) {
        state = AsyncValue.data(user);
      },
      onError: (e, st) {
        state = AsyncValue.error(e, st);
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Actions
  // -------------------------------------------------------------------------

  Future<void> signIn(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      final user = await _repository.signIn(email, password);
      state = AsyncValue.data(user);
    } on AppError catch (e, st) {
      state = AsyncValue.error(e, st);
    } catch (e, st) {
      state = AsyncValue.error(
        NetworkError(detail: e.toString()),
        st,
      );
    }
  }

  Future<void> signInWithOtp(String phone, String otp) async {
    try {
      state = const AsyncValue.loading();
      final user = await _repository.signInWithOtp(phone, otp);
      state = AsyncValue.data(user);
    } on AppError catch (e, st) {
      state = AsyncValue.error(e, st);
    } catch (e, st) {
      state = AsyncValue.error(NetworkError(detail: e.toString()), st);
    }
  }

  Future<void> signInAsRole(
    app_user.UserRole role,
    String email,
    String password,
  ) async {
    try {
      state = const AsyncValue.loading();
      final user = await _repository.signInAsRole(role, email, password);
      state = AsyncValue.data(user);
    } on AppError catch (e, st) {
      state = AsyncValue.error(e, st);
    } catch (e, st) {
      state = AsyncValue.error(NetworkError(detail: e.toString()), st);
    }
  }

  Future<void> signOut() async {
    try {
      await _repository.signOut();
      // State is updated by the authStateChanges stream
    } catch (e, st) {
      state = AsyncValue.error(NetworkError(detail: e.toString()), st);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    await _repository.sendPasswordReset(email);
  }

  /// Legacy shim used by some screens that call [signInAsStudent] directly.
  Future<void> signInAsStudent(app_user.User user) async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(user);
  }

  /// Legacy shim — kept for backwards compatibility with existing login pages.
  Future<void> signInAsTeacher(String email, String password) =>
      signInAsRole(app_user.UserRole.teacher, email, password);

  /// Legacy shim — kept for backwards compatibility.
  Future<void> createUserWithEmailAndPassword(
    String email,
    String password,
    String name,
    app_user.UserRole role,
    String phone,
  ) async {
    // For Phase 2, delegate to signIn (registration added in Phase 3).
    await signIn(email, password);
  }

  Future<void> updateUserProfile({
    String? name,
    String? photoUrl,
    app_user.UserRole? role,
    String? phone,
    String? department,
    String? year,
    String? section,
  }) async {
    try {
      final updated = await _repository.updateProfile(
        name: name,
        photoUrl: photoUrl,
        phone: phone,
        department: department,
        year: year,
        section: section,
      );
      state = AsyncValue.data(updated);
    } on AppError catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clearUser() => state = const AsyncValue.data(null);
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// The primary auth state provider – replaces the old [authProvider].
final authProvider =
    StateNotifierProvider<AuthController, AsyncValue<app_user.User?>>(
  (ref) => AuthController(ref.watch(authRepositoryProvider)),
);

/// Convenience provider that yields the current user or null.
final currentUserProvider = Provider<app_user.User?>((ref) {
  return ref.watch(authProvider).value;
});

/// True when a user is signed in.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).value != null;
});
