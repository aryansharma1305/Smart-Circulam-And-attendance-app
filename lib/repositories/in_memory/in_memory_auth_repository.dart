import 'dart:async';
import '../../models/user.dart';
import '../../core/app_error.dart';
import '../auth_repository.dart';

/// In-memory [AuthRepository] for tests and demo mode.
///
/// Seeds three users (student, teacher, admin) with well-known credentials:
///
/// | Role    | Email                  | Password  |
/// |---------|------------------------|-----------|
/// | Student | student@demo.edu       | demo1234  |
/// | Teacher | teacher@demo.edu       | demo1234  |
/// | Admin   | admin@demo.edu         | demo1234  |
///
/// Any 6-digit OTP is accepted for OTP sign-in.
class InMemoryAuthRepository implements AuthRepository {
  InMemoryAuthRepository() {
    _seedUsers();
  }

  final Map<String, User> _usersByEmail = {};
  User? _currentUser;
  final _authStateController = StreamController<User?>.broadcast();

  // -------------------------------------------------------------------------
  // Seed
  // -------------------------------------------------------------------------

  static final _now = DateTime(2025, 1, 1);

  void _seedUsers() {
    final users = [
      User(
        uid: 'student-001',
        name: 'Alex Johnson',
        phone: '+919000000001',
        email: 'student@demo.edu',
        role: UserRole.student,
        department: 'Computer Science',
        year: '2024',
        section: 'A',
        subjects: ['Mathematics', 'Physics', 'Chemistry', 'English'],
        institutionCode: 'DEMO_UNI',
        createdAt: _now,
        lastActive: _now,
      ),
      User(
        uid: 'teacher-001',
        name: 'Prof. Sarah Williams',
        phone: '+919000000002',
        email: 'teacher@demo.edu',
        role: UserRole.teacher,
        department: 'Mathematics',
        subjects: ['Mathematics', 'Calculus', 'Linear Algebra', 'Statistics'],
        institutionCode: 'DEMO_UNI',
        deviceHash: 'teacher_device_hash',
        createdAt: _now,
        lastActive: _now,
      ),
      User(
        uid: 'admin-001',
        name: 'Dr. Kumar Patel',
        phone: '+919000000003',
        email: 'admin@demo.edu',
        role: UserRole.admin,
        institutionCode: 'DEMO_UNI',
        createdAt: _now,
        lastActive: _now,
      ),
    ];

    for (final u in users) {
      _usersByEmail[u.email] = u;
    }
  }

  // -------------------------------------------------------------------------
  // AuthRepository implementation
  // -------------------------------------------------------------------------

  @override
  Future<User?> getCurrentUser() async => _currentUser;

  @override
  Stream<User?> get authStateChanges => _authStateController.stream;

  @override
  Future<User> signIn(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw const ValidationError(
        fields: {
          'email': 'Email cannot be empty',
          'password': 'Password cannot be empty',
        },
      );
    }

    final user = _usersByEmail[email.toLowerCase()];
    if (user == null || password != 'demo1234') {
      throw const AuthorizationError(detail: 'Invalid email or password.');
    }

    _currentUser = user;
    _authStateController.add(user);
    return user;
  }

  @override
  Future<User> signInWithOtp(String phone, String otp) async {
    if (otp.length != 6) {
      throw const ValidationError(
        fields: {'otp': 'OTP must be exactly 6 digits.'},
      );
    }

    // Accept any 6-digit OTP; return the seeded student.
    final user = _usersByEmail['student@demo.edu']!;
    _currentUser = user;
    _authStateController.add(user);
    return user;
  }

  @override
  Future<User> signInAsRole(
    UserRole role,
    String email,
    String password,
  ) async {
    final user = await signIn(email, password);
    if (user.role != role) {
      throw AuthorizationError(
        detail: 'Account is registered as ${user.roleDisplayName}, '
            'not ${role.name}.',
      );
    }
    return user;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    if (email.isEmpty) {
      throw const ValidationError(
        fields: {'email': 'Email cannot be empty'},
      );
    }
    // Simulate sending email success
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
    if (_currentUser == null) {
      throw const AuthorizationError(detail: 'No user is signed in.');
    }

    final updated = _currentUser!.copyWith(
      name: name,
      photoUrl: photoUrl,
      phone: phone,
      department: department,
      year: year,
      section: section,
    );

    _usersByEmail[updated.email] = updated;
    _currentUser = updated;
    return updated;
  }

  // -------------------------------------------------------------------------
  // Test helpers (not part of the interface)
  // -------------------------------------------------------------------------

  /// Clears the current session (useful between tests).
  void reset() => _currentUser = null;

  /// Returns all seeded users (for assertion in tests).
  List<User> get allUsers => List.unmodifiable(_usersByEmail.values);
}
