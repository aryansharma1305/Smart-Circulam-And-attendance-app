import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';

class TestNavigationPage extends StatelessWidget {
  const TestNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Navigation'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Navigation Test Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/student/attendance'),
              child: const Text('Go to Attendance'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => context.go('/student/ledger'),
              child: const Text('Go to Ledger'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => context.go('/student/goals'),
              child: const Text('Go to Goals'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => context.go('/student/calendar'),
              child: const Text('Go to Calendar'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => context.go('/student/reports'),
              child: const Text('Go to Reports'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => context.go('/student/notifications'),
              child: const Text('Go to Notifications'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => context.go('/student/profile'),
              child: const Text('Go to Profile'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/student'),
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
