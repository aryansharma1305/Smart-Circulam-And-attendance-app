import 'package:flutter/material.dart';

class AnalyticsDashboardPageSimple extends StatelessWidget {
  const AnalyticsDashboardPageSimple({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Analytics Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Random analytics data will be displayed here'),
          ],
        ),
      ),
    );
  }
}
