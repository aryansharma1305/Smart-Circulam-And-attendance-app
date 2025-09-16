import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class CounsellorDashboard extends StatefulWidget {
  const CounsellorDashboard({super.key});

  @override
  State<CounsellorDashboard> createState() => _CounsellorDashboardState();
}

class _CounsellorDashboardState extends State<CounsellorDashboard> {
  final List<DashboardCard> _dashboardCards = [
    DashboardCard(
      title: 'Active Sessions',
      subtitle: 'Ongoing counselling sessions',
      icon: Icons.psychology,
      color: Colors.teal,
      route: '/counsellor/sessions',
      count: '3',
    ),
    DashboardCard(
      title: 'Student Profiles',
      subtitle: 'View student progress',
      icon: Icons.person_search,
      color: Colors.blue,
      route: '/counsellor/students',
      count: '45',
    ),
    DashboardCard(
      title: 'Appointments',
      subtitle: 'Schedule and manage meetings',
      icon: Icons.calendar_today,
      color: Colors.orange,
      route: '/counsellor/appointments',
      count: '12',
    ),
    DashboardCard(
      title: 'Goal Tracking',
      subtitle: 'Monitor student goals',
      icon: Icons.track_changes,
      color: Colors.green,
      route: '/counsellor/goals',
      count: '28',
    ),
    DashboardCard(
      title: 'Reports',
      subtitle: 'Generate progress reports',
      icon: Icons.assessment,
      color: Colors.purple,
      route: '/counsellor/reports',
      count: '8',
    ),
    DashboardCard(
      title: 'Resources',
      subtitle: 'Counselling materials',
      icon: Icons.library_books,
      color: Colors.indigo,
      route: '/counsellor/resources',
      count: '',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counsellor Dashboard'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => context.push('/counsellor/notifications'),
          ),
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
            colors: [Colors.teal.shade700, Colors.teal.shade50],
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/counsellor/new-session'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Session'),
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
            'Welcome, Counsellor',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fadeIn(duration: 600.ms).slideX(),
          const SizedBox(height: 8),
          Text(
            'Guide students to success',
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
              context.go('/onboarding');
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
