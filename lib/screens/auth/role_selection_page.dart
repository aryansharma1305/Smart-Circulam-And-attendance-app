import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // App Logo and Title
                  _buildHeader(),

                  const SizedBox(height: 60),

                  // Role Selection Prompt
                  Text(
                        'I am a...',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: const Duration(milliseconds: 600))
                      .slideY(begin: 0.3),

                  const SizedBox(height: 40),

                  // Role Cards
                  _buildRoleCards(context),

                  const SizedBox(height: 40),

                  // Continue Button
                  _buildContinueButton(context),

                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.school, size: 40, color: Colors.white),
        ).animate().scale(
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
        ),

        const SizedBox(height: 24),

        // App Name
        Text(
              'SmartStudy+',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
            .animate()
            .fadeIn(duration: const Duration(milliseconds: 600))
            .slideY(begin: 0.3),

        const SizedBox(height: 8),

        // Tagline
        Text(
              'Automated attendance + smart daily planning',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            )
            .animate()
            .fadeIn(duration: const Duration(milliseconds: 600))
            .slideY(begin: 0.3),
      ],
    );
  }

  Widget _buildRoleCards(BuildContext context) {
    return Column(
      children: [
        // First Row
        Row(
          children: [
            Expanded(
              child: _buildRoleCard(
                context,
                title: 'Student',
                description: 'Mark attendance & track progress',
                icon: Icons.person,
                onTap: () => context.go('/student/onboarding'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildRoleCard(
                context,
                title: 'Teacher',
                description: 'Start sessions & track classes',
                icon: Icons.school,
                onTap: () => context.go('/login'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        _buildRoleCard(
          context,
          title: 'Admin',
          description: 'Manage institute & view reports',
          icon: Icons.admin_panel_settings,
          onTap: () => context.go('/login'),
        ),
      ],
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(icon, size: 32, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(begin: 0.3);
  }

  Widget _buildContinueButton(BuildContext context) {
    return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              // Show role selection dialog or go to default
              _showRoleSelectionDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Continue',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(begin: 0.3);
  }

  void _showRoleSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Quick Access'),
        content: const Text('Choose a role to explore the app quickly.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/student/onboarding');
            },
            child: const Text('Student'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/login');
            },
            child: const Text('Teacher/Admin Login'),
          ),
        ],
      ),
    );
  }
}
