import 'package:flutter/material.dart';
import '../../core/theme.dart';

class LiveboardPage extends StatelessWidget {
  final String sessionId;
  
  const LiveboardPage({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LiveBoard - Session $sessionId'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('LiveBoard Coming Soon'),
      ),
    );
  }
}
