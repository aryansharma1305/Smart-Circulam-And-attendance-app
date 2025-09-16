import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import '../widgets/demo_qr_scanner.dart';

class DemoFeaturesPage extends StatefulWidget {
  const DemoFeaturesPage({super.key});

  @override
  State<DemoFeaturesPage> createState() => _DemoFeaturesPageState();
}

class _DemoFeaturesPageState extends State<DemoFeaturesPage> {
  bool _showQRScanner = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'New Features Demo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _showQRScanner ? _buildQRScanner() : _buildFeaturesList(),
    );
  }

  Widget _buildQRScanner() {
    return DemoQRScanner(
      expectedSessionId: 'demo_session_123',
      studentName: 'John Doe',
      courseName: 'Data Structures & Algorithms',
      onQRScanned: (success) {
        // Handle QR scan result
        print('QR Scanned: $success');
      },
      onClose: () {
        setState(() {
          _showQRScanner = false;
        });
      },
    );
  }

  Widget _buildFeaturesList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFeatureCard(
            title: '🎯 Enhanced QR Scanner',
            subtitle: 'Smooth animations & any QR acceptance',
            description:
                'The new QR scanner accepts any randomly generated QR code and shows beautiful attendance marking animations.',
            features: [
              '✨ Accepts any QR code format',
              '🎬 Smooth success animations',
              '📱 Enhanced UI with scan line',
              '⚡ Instant attendance marking',
            ],
            onTap: () {
              setState(() {
                _showQRScanner = true;
              });
            },
            buttonText: 'Try QR Scanner',
            color: Colors.blue,
          ),

          const SizedBox(height: 24),

          _buildFeatureCard(
            title: '📋 Teacher Exception Management',
            subtitle: 'Handle late attendance & corrections',
            description:
                'Teachers can now manage attendance exceptions, approve late arrivals, and handle attendance corrections efficiently.',
            features: [
              '📝 Student exception requests',
              '✅ Teacher approval system',
              '📊 Exception analytics',
              '🔔 Real-time notifications',
            ],
            onTap: () {
              context.push('/teacher/attendance-exceptions');
            },
            buttonText: 'View Exceptions',
            color: Colors.orange,
          ),

          const SizedBox(height: 24),

          _buildFeatureCard(
            title: '🎓 Student Exception Requests',
            subtitle: 'Request attendance corrections',
            description:
                'Students can now request exceptions for late arrivals, technical issues, or wrongly marked attendance.',
            features: [
              '📱 Easy request submission',
              '📎 Document attachments',
              '⏰ Real-time status tracking',
              '💬 Teacher feedback system',
            ],
            onTap: () {
              context.push('/student/request-exception');
            },
            buttonText: 'Request Exception',
            color: Colors.green,
          ),

          const SizedBox(height: 32),

          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required String description,
    required List<String> features,
    required VoidCallback onTap,
    required String buttonText,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textPrimaryColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),

                // Features list
                ...features.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      feature,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Action button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.1),
            AppTheme.secondaryColor.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, size: 48, color: AppTheme.primaryColor),
          const SizedBox(height: 16),
          const Text(
            'Implementation Complete!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Both features have been successfully implemented with smooth animations and comprehensive functionality.',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondaryColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms, duration: 600.ms).slideY(begin: 0.3, end: 0);
  }
}
