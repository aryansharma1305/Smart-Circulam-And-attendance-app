import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final List<DashboardCard> _dashboardCards = [
    DashboardCard(
      title: 'Academic Setup',
      subtitle: 'Departments, terms, subjects and rooms',
      icon: Icons.account_tree,
      color: Colors.indigo,
      route: '/admin/academics',
      count: '',
    ),
    DashboardCard(
      title: 'Manage Teachers',
      subtitle: 'Add, edit, and assign teachers',
      icon: Icons.person_add,
      color: Colors.blue,
      route: '/admin/teachers',
      count: '24',
    ),
    DashboardCard(
      title: 'Bulk Import',
      subtitle: 'Preview user and enrollment imports',
      icon: Icons.class_,
      color: Colors.green,
      route: '/admin/bulk-import',
      count: '',
    ),
    DashboardCard(
      title: 'Timetable',
      subtitle: 'Review the institute timetable',
      icon: Icons.school,
      color: Colors.orange,
      route: '/admin/timetable',
      count: '',
    ),
    DashboardCard(
      title: 'Compliance',
      subtitle: 'View attendance compliance metrics',
      icon: Icons.analytics,
      color: Colors.purple,
      route: '/admin/compliance',
      count: '',
    ),
    DashboardCard(
      title: 'Audit Logs',
      subtitle: 'Review administrative activity',
      icon: Icons.pending_actions,
      color: Colors.red,
      route: '/admin/audit',
      count: '',
    ),
    DashboardCard(
      title: 'System Settings',
      subtitle: 'Configure app settings',
      icon: Icons.settings,
      color: Colors.grey,
      route: '/admin',
      count: '',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade700, Colors.blue.shade50],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildWelcomeSection(),
              Expanded(child: _buildDashboardGrid()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, Admin',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fadeIn(duration: 600.ms).slideX(),
          const SizedBox(height: 8),
          Text(
            'Manage your school efficiently',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideX(),
        ],
      ),
    );
  }

  Widget _buildDashboardGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _dashboardCards.length,
        itemBuilder: (context, index) {
          final card = _dashboardCards[index];
          return _buildDashboardCard(card, index);
        },
      ),
    );
  }

  Widget _buildDashboardCard(DashboardCard card, int index) {
    return Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () => context.push(card.route),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    card.color.withValues(alpha: 0.1),
                    card.color.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: card.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(card.icon, color: card.color, size: 24),
                      ),
                      if (card.count.isNotEmpty)
                        Text(
                          card.count,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: card.color,
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    card.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card.subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(delay: (index * 100).ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.3);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class DashboardCard {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;
  final String count;

  DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
    required this.count,
  });
}
