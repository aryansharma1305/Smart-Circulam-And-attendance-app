import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../core/theme.dart';

class DebugPage extends ConsumerWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Page'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Debug Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Auth State:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 10),

            authState.when(
              data: (user) => Text(
                user == null
                    ? 'No user logged in'
                    : 'User: ${user.name} (${user.role})',
                style: TextStyle(
                  fontSize: 16,
                  color: user == null ? Colors.red : Colors.green,
                ),
              ),
              loading: () => const Text('Loading...'),
              error: (error, stack) => Text('Error: $error'),
            ),

            const SizedBox(height: 30),

            Text(
              'Actions:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                ref.read(authProvider.notifier).clearUser();
                context.go('/onboarding');
              },
              child: const Text('Clear User & Go to Onboarding'),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                context.go('/student/onboarding');
              },
              child: const Text('Go to Student Onboarding'),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                context.go('/role-selection');
              },
              child: const Text('Go to Role Selection'),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                context.go('/test-qr');
              },
              child: const Text('Test QR Code Functionality'),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                // Create a dummy student user
                ref
                    .read(authProvider.notifier)
                    .signInAsStudent(
                      User(
                        uid:
                            'debug_student_${DateTime.now().millisecondsSinceEpoch}',
                        email: 'debug@student.com',
                        name: 'Debug Student',
                        phone: '+1234567890',
                        role: UserRole.student,
                        department: 'Computer Science',
                        year: '2024',
                        section: 'A',
                        subjects: ['Mathematics', 'Physics', 'Chemistry'],
                        createdAt: DateTime.now(),
                        lastActive: DateTime.now(),
                      ),
                    );
                context.go('/student');
              },
              child: const Text('Login as Debug Student'),
            ),
          ],
        ),
      ),
    );
  }
}
