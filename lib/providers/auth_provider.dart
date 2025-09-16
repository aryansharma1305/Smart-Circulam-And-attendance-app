import 'package:flutter_riverpod/flutter_riverpod.dart';
// Demo auth - simulating Firebase Auth
import '../models/user.dart' as app_user;

class AuthNotifier extends StateNotifier<AsyncValue<app_user.User?>> {
  String? _auth;

  AuthNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    try {
      _auth = 'demo_auth_instance';
    } catch (e) {
      // Firebase not available, use demo mode
      _auth = null;
    }
    // Force no user initially to show login flow
    state = const AsyncValue.data(null);
  }

  // Add method to clear user state
  void clearUser() {
    state = const AsyncValue.data(null);
  }

  Future<void> _getUserData(String? firebaseUser) async {
    if (firebaseUser == null) return;
    try {
      // In a real app, you'd fetch user data from Firestore
      final user = app_user.User(
        uid: 'demo_user_123',
        email: 'demo@example.com',
        name: 'Demo User',
        phone: '+1234567890', // Demo phone
        role: app_user.UserRole.student, // Default role, can be updated
        photoUrl: null,
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      state = const AsyncValue.loading();

      // Always use demo mode for now
      if (email.isNotEmpty && password.isNotEmpty) {
        final user = app_user.User(
          uid: 'demo_user_${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          name: 'Demo User',
          phone: '+1234567890',
          role: app_user.UserRole.student,
          department: 'Computer Science',
          year: '2024',
          section: 'A',
          subjects: ['Mathematics', 'Physics', 'Chemistry', 'English'],
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
        );
        state = AsyncValue.data(user);
      } else {
        throw Exception('Please enter email and password');
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> createUserWithEmailAndPassword(
    String email,
    String password,
    String name,
    app_user.UserRole role,
    String phone,
  ) async {
    try {
      state = const AsyncValue.loading();

      // Always use demo mode for now
      if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty) {
        final user = app_user.User(
          uid: 'demo_user_${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          name: name,
          phone: phone,
          role: role,
          department: role == app_user.UserRole.teacher
              ? 'Mathematics'
              : 'Computer Science',
          year: role == app_user.UserRole.student ? '2024' : null,
          section: role == app_user.UserRole.student ? 'A' : null,
          subjects: role == app_user.UserRole.student
              ? ['Mathematics', 'Physics', 'Chemistry', 'English']
              : ['Mathematics', 'Calculus', 'Linear Algebra', 'Statistics'],
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
        );

        state = AsyncValue.data(user);
      } else {
        throw Exception('Please fill in all required fields');
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signInWithOtp(String phone, String otp) async {
    try {
      state = const AsyncValue.loading();

      // For demo purposes, accept any 6-digit OTP
      if (otp.length == 6) {
        // Create a dummy student user for demo
        final user = app_user.User(
          uid: 'demo_student_${DateTime.now().millisecondsSinceEpoch}',
          email: 'student@demo.com',
          name: 'Demo Student',
          phone: phone,
          role: app_user.UserRole.student,
          department: 'Computer Science',
          year: '2024',
          section: 'A',
          subjects: ['Mathematics', 'Physics', 'Chemistry', 'English'],
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
        );

        state = AsyncValue.data(user);
      } else {
        throw Exception('Invalid OTP');
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signInAsTeacher(String email, String password) async {
    try {
      print('signInAsTeacher called with email: $email');
      state = const AsyncValue.loading();

      // For demo purposes, accept any email/password for teachers
      if (email.isNotEmpty && password.isNotEmpty) {
        // Create a dummy teacher user for demo
        final user = app_user.User(
          uid: 'demo_teacher_${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          name: 'Demo Teacher',
          phone: '+1234567890',
          role: app_user.UserRole.teacher,
          department: 'Mathematics',
          subjects: ['Mathematics', 'Calculus', 'Linear Algebra', 'Statistics'],
          interests: [],
          strengths: [],
          goals: [],
          privacy: {},
          deviceHash: 'teacher_device_hash',
          institutionCode: 'DEMO_UNI',
          preferences: {},
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
        );

        print('Created teacher user with role: ${user.role}');
        state = AsyncValue.data(user);
      } else {
        throw Exception('Invalid credentials');
      }
    } catch (e) {
      print('Error in signInAsTeacher: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signInAsStudent(app_user.User user) async {
    try {
      state = const AsyncValue.loading();
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signOut() async {
    try {
      // Demo mode - just clear the user state
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
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
      final currentUser = state.value;
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          name: name ?? currentUser.name,
          photoUrl: photoUrl ?? currentUser.photoUrl,
          role: role ?? currentUser.role,
          phone: phone ?? currentUser.phone,
          department: department ?? currentUser.department,
          year: year ?? currentUser.year,
          section: section ?? currentUser.section,
        );
        state = AsyncValue.data(updatedUser);

        // Update in Firestore (in real app)
        if (name != null) {
          // Demo: simulate updating display name
          print('Demo: Updated display name to $name');
        }
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<app_user.User?>>(
      (ref) => AuthNotifier(),
    );

final currentUserProvider = Provider<app_user.User?>((ref) {
  return ref.watch(authProvider).value;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).value != null;
});
