import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'auth_guard.dart';
import '../screens/auth/onboarding_page.dart';
import '../screens/auth/role_selection_page.dart';
import '../screens/auth/login_page.dart';
import '../screens/auth/otp_login_page.dart';
import '../screens/auth/profile_setup_page.dart';
import '../screens/auth/forgot_password_page.dart';
import '../screens/student/student_onboarding_page.dart';
import '../screens/student/student_dashboard_page.dart';
import '../screens/student/enhanced_multi_modal_attendance_page.dart';
import '../screens/student/attendance_ledger_page.dart';
import '../screens/student/goals_planner_page.dart';
import '../screens/student/free_period_coach_page.dart';
import '../screens/student/timetable_page.dart';
import '../screens/student/student_profile_page.dart';
import '../screens/student/student_calendar_page.dart';
import '../screens/student/student_reports_page.dart';
import '../screens/student/student_notifications_page.dart';
import '../screens/student/test_navigation_page.dart';
import '../screens/student/request_attendance_exception_page.dart';
import '../screens/debug_page.dart';
import '../screens/teacher/teacher_home_page.dart';
import '../screens/teacher/start_session_page_simple.dart';
import '../screens/teacher/roster_page.dart';
import '../screens/teacher/subject_analytics_page_simple.dart';
import '../screens/teacher/analytics_dashboard_page_simple.dart';
import '../screens/teacher/teacher_timetable_page.dart';
import '../screens/teacher/teacher_sessions_page.dart';
import '../screens/teacher/announce_page.dart';
import '../screens/teacher/create_announcement_page.dart';
import '../screens/teacher/attendance_display_page.dart';
import '../screens/teacher/attendance_exceptions_page.dart';
import '../screens/admin/setup_page.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/teacher_management_page.dart';
import '../screens/admin/bulk_import_page.dart';
import '../screens/admin/timetable_admin_page.dart';
import '../screens/admin/compliance_dashboard_page.dart';
import '../screens/admin/audit_logs_page.dart';
import '../screens/admin/academic_management_page.dart';
import '../screens/liveboard/liveboard_page.dart';
import '../screens/test_qr_page.dart';
import '../screens/demo_features_page.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/onboarding',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isAuthRoute =
          state.matchedLocation.startsWith('/onboarding') ||
          state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/otp-login') ||
          state.matchedLocation.startsWith('/forgot-password') ||
          state.matchedLocation.startsWith('/role-selection') ||
          state.matchedLocation.startsWith('/profile-setup');

      if (!isLoggedIn && !isAuthRoute) return '/onboarding';

      if (isLoggedIn) {
        final role = authState.value!.role;

        // Prevent cross-role navigation
        if (role == UserRole.student) {
          if (state.matchedLocation.startsWith('/teacher') ||
              state.matchedLocation.startsWith('/admin')) {
            return '/student';
          }
        } else if (role == UserRole.teacher) {
          if (state.matchedLocation.startsWith('/student') ||
              state.matchedLocation.startsWith('/admin')) {
            return '/teacher';
          }
        } else if (role == UserRole.admin) {
          if (state.matchedLocation.startsWith('/student') ||
              state.matchedLocation.startsWith('/teacher')) {
            return '/admin/dashboard';
          }
        }

        // Redirect from auth routes if already logged in
        if (isAuthRoute) {
          switch (role) {
            case UserRole.student:
            case UserRole.parent:
              return '/student';
            case UserRole.teacher:
              return '/teacher';
            case UserRole.admin:
              return '/admin/dashboard';
            case UserRole.counselor:
              return '/student'; // Placeholder for counselor
          }
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(path: '/debug', builder: (context, state) => const DebugPage()),
      GoRoute(
        path: '/test-qr',
        builder: (context, state) => const TestQRPage(),
      ),
      GoRoute(
        path: '/demo-features',
        builder: (context, state) => const DemoFeaturesPage(),
      ),
      GoRoute(
        path: '/role-selection',
        builder: (context, state) => const RoleSelectionPage(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/otp-login',
        builder: (context, state) => const OtpLoginPage(),
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/student/onboarding',
        builder: (context, state) => const StudentOnboardingPage(),
      ),
      GoRoute(
        path: '/student',
        builder: (context, state) =>
            const AuthGuard(child: StudentDashboardPage()),
      ),
      GoRoute(
        path: '/student/attendance',
        builder: (context, state) =>
            const AuthGuard(child: EnhancedMultiModalAttendancePage()),
      ),
      GoRoute(
        path: '/student/ledger',
        builder: (context, state) =>
            const AuthGuard(child: AttendanceLedgerPage()),
      ),
      GoRoute(
        path: '/student/goals',
        builder: (context, state) => const AuthGuard(child: GoalsPlannerPage()),
      ),
      GoRoute(
        path: '/student/coach',
        builder: (context, state) =>
            const AuthGuard(child: FreePeriodCoachPage()),
      ),
      GoRoute(
        path: '/student/timetable',
        builder: (context, state) => const AuthGuard(child: TimetablePage()),
      ),
      GoRoute(
        path: '/student/profile',
        builder: (context, state) =>
            const AuthGuard(child: StudentProfilePage()),
      ),
      GoRoute(
        path: '/student/calendar',
        builder: (context, state) =>
            const AuthGuard(child: StudentCalendarPage()),
      ),
      GoRoute(
        path: '/student/reports',
        builder: (context, state) =>
            const AuthGuard(child: StudentReportsPage()),
      ),
      GoRoute(
        path: '/student/notifications',
        builder: (context, state) =>
            const AuthGuard(child: StudentNotificationsPage()),
      ),
      GoRoute(
        path: '/student/test',
        builder: (context, state) =>
            const AuthGuard(child: TestNavigationPage()),
      ),
      GoRoute(
        path: '/student/request-exception',
        builder: (context, state) =>
            const AuthGuard(child: RequestAttendanceExceptionPage()),
      ),

      GoRoute(
        path: '/teacher',
        builder: (context, state) => const AuthGuard(child: TeacherHomePage()),
      ),
      GoRoute(
        path: '/teacher/start-session',
        builder: (context, state) => AuthGuard(
          child: StartSessionPage(
            classData:
                state.extra as Map<String, dynamic>? ??
                {
                  'subject': 'Demo Subject',
                  'time': '10:00 AM',
                  'room': 'Room 101',
                  'timetableId': 'demo_id',
                  'start': DateTime.now(),
                },
          ),
        ),
      ),
      GoRoute(
        path: '/teacher/roster',
        builder: (context, state) => const AuthGuard(child: RosterPage()),
      ),
      GoRoute(
        path: '/teacher/analytics',
        builder: (context, state) =>
            const AuthGuard(child: SubjectAnalyticsPageSimple()),
      ),
      GoRoute(
        path: '/teacher/analytics-dashboard',
        builder: (context, state) =>
            const AuthGuard(child: AnalyticsDashboardPageSimple()),
      ),
      GoRoute(
        path: '/teacher/timetable',
        builder: (context, state) =>
            const AuthGuard(child: TeacherTimetablePage()),
      ),
      GoRoute(
        path: '/teacher/sessions',
        builder: (context, state) =>
            const AuthGuard(child: TeacherSessionsPage()),
      ),
      GoRoute(
        path: '/teacher/announcements',
        builder: (context, state) => const AuthGuard(child: AnnouncePage()),
      ),
      GoRoute(
        path: '/teacher/create-announcement',
        builder: (context, state) =>
            const AuthGuard(child: CreateAnnouncementPage()),
      ),
      GoRoute(
        path: '/teacher/attendance-display',
        builder: (context, state) =>
            const AuthGuard(child: AttendanceDisplayPage()),
      ),
      GoRoute(
        path: '/teacher/attendance-exceptions',
        builder: (context, state) =>
            const AuthGuard(child: AttendanceExceptionsPage()),
      ),

      // Admin Routes
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AuthGuard(child: SetupPage()),
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AuthGuard(child: AdminDashboard()),
      ),
      GoRoute(
        path: '/admin/teachers',
        builder: (context, state) =>
            const AuthGuard(child: TeacherManagementPage()),
      ),
      GoRoute(
        path: '/admin/academics',
        builder: (context, state) =>
            const AuthGuard(child: AcademicManagementPage()),
      ),
      GoRoute(
        path: '/admin/bulk-import',
        builder: (context, state) => const AuthGuard(child: BulkImportPage()),
      ),
      GoRoute(
        path: '/admin/timetable',
        builder: (context, state) =>
            const AuthGuard(child: TimetableAdminPage()),
      ),
      GoRoute(
        path: '/admin/compliance',
        builder: (context, state) =>
            const AuthGuard(child: ComplianceDashboardPage()),
      ),
      GoRoute(
        path: '/admin/audit',
        builder: (context, state) => const AuthGuard(child: AuditLogsPage()),
      ),

      GoRoute(
        path: '/liveboard/:sessionId',
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId'] ?? '';
          return LiveboardPage(sessionId: sessionId);
        },
      ),
    ],
  );
});

class AppNavigation {
  static void goToStudentHome(BuildContext context) {
    context.go('/student');
  }

  static void goToTeacherHome(BuildContext context) {
    context.go('/teacher');
  }

  static void goToAdminHome(BuildContext context) {
    context.go('/admin/dashboard');
  }

  static void goToStudentOnboarding(BuildContext context) {
    context.go('/student/onboarding');
  }

  static void goToStudentAttendance(BuildContext context) {
    context.go('/student/attendance');
  }

  static void goToStudentLedger(BuildContext context) {
    context.go('/student/ledger');
  }

  static void goToStudentGoals(BuildContext context) {
    context.go('/student/goals');
  }

  static void goToStudentCoach(BuildContext context) {
    context.go('/student/coach');
  }

  static void goToStartSession(BuildContext context) {
    context.go('/teacher/start-session');
  }

  static void goToLiveboard(BuildContext context, String sessionId) {
    context.go('/liveboard/$sessionId');
  }

  static void goToAttendanceDisplay(BuildContext context, String sessionId) {
    context.go('/teacher/attendance-display', extra: sessionId);
  }
}
