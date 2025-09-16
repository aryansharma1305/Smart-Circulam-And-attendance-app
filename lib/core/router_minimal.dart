import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/onboarding_page.dart';
import '../screens/auth/role_selection_page.dart';
import '../screens/student/student_dashboard_page.dart';
import '../screens/teacher/teacher_home_page.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/counsellor/counsellor_dashboard.dart';
import '../screens/role_navigation_demo.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/role-navigation-demo',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/role-selection',
      builder: (context, state) => const RoleSelectionPage(),
    ),
    GoRoute(
      path: '/role-navigation-demo',
      builder: (context, state) => const RoleNavigationDemo(),
    ),
    GoRoute(
      path: '/student',
      builder: (context, state) => const StudentDashboardPage(),
    ),
    GoRoute(
      path: '/student-dashboard',
      builder: (context, state) => const StudentDashboardPage(),
    ),
    GoRoute(
      path: '/teacher-home',
      builder: (context, state) => const TeacherHomePage(),
    ),
    GoRoute(
      path: '/admin-dashboard',
      builder: (context, state) => const AdminDashboard(),
    ),
    GoRoute(
      path: '/counsellor-dashboard',
      builder: (context, state) => const CounsellorDashboard(),
    ),
  ],
);
