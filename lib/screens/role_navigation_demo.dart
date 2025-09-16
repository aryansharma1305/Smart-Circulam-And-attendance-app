import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RoleNavigationDemo extends StatelessWidget {
  const RoleNavigationDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Role Navigation Demo'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade700, Colors.indigo.shade50],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 40),
                Expanded(child: _buildRoleCards(context)),
                _buildBackButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          Icons.dashboard,
          size: 64,
          color: Colors.white,
        ).animate().scale(duration: 600.ms),
        const SizedBox(height: 16),
        Text(
          'All Dashboards Ready!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ).animate().fadeIn(duration: 600.ms),
        const SizedBox(height: 8),
        Text(
          'Navigate to any role dashboard',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
      ],
    );
  }

  Widget _buildRoleCards(BuildContext context) {
    final roles = [
      RoleCard(
        title: 'Student Dashboard',
        description: 'QR attendance, goals, analytics',
        icon: Icons.person,
        color: Colors.blue,
        route: '/student',
        features: ['QR Scanner', 'Attendance Tracking', 'Goal Planning'],
      ),
      RoleCard(
        title: 'Teacher Dashboard',
        description: 'Sessions, roster, analytics',
        icon: Icons.school,
        color: Colors.green,
        route: '/teacher',
        features: ['Start Sessions', 'View Roster', 'Analytics'],
      ),
      RoleCard(
        title: 'Admin Dashboard',
        description: 'Manage teachers, classes, reports',
        icon: Icons.admin_panel_settings,
        color: Colors.orange,
        route: '/admin/dashboard',
        features: ['Teacher Management', 'Class Management', 'Reports'],
      ),
      RoleCard(
        title: 'Counsellor Dashboard',
        description: 'Student guidance, sessions, goals',
        icon: Icons.psychology,
        color: Colors.purple,
        route: '/counsellor',
        features: ['Counselling Sessions', 'Student Progress', 'Goal Tracking'],
      ),
    ];

    return ListView.builder(
      itemCount: roles.length,
      itemBuilder: (context, index) {
        final role = roles[index];
        return _buildRoleCard(context, role, index);
      },
    );
  }

  Widget _buildRoleCard(BuildContext context, RoleCard role, int index) {
    return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () => context.go(role.route),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    role.color.withValues(alpha: 0.1),
                    role.color.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: role.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(role.icon, color: role.color, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          role.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          role.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: role.features.map((feature) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: role.color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                feature,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: role.color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: role.color, size: 20),
                ],
              ),
            ),
          ),
        )
        .animate(delay: (index * 100).ms)
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.3);
  }

  Widget _buildBackButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => context.go('/role-selection'),
        icon: const Icon(Icons.arrow_back),
        label: const Text('Back to Role Selection'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.indigo.shade700,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class RoleCard {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;
  final List<String> features;

  RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
    required this.features,
  });
}
