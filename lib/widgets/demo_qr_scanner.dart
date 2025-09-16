import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import 'attendance_success_animation.dart';

class DemoQRScanner extends StatefulWidget {
  final String expectedSessionId;
  final String studentName;
  final String courseName;
  final Function(bool) onQRScanned;
  final VoidCallback? onClose;

  const DemoQRScanner({
    super.key,
    required this.expectedSessionId,
    required this.studentName,
    required this.courseName,
    required this.onQRScanned,
    this.onClose,
  });

  @override
  State<DemoQRScanner> createState() => _DemoQRScannerState();
}

class _DemoQRScannerState extends State<DemoQRScanner>
    with TickerProviderStateMixin {
  bool _showSuccessAnimation = false;
  late AnimationController _scanLineController;
  late AnimationController _cornerController;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _cornerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scanLineController.repeat();
    _cornerController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _cornerController.dispose();
    super.dispose();
  }

  void _onQRScanned() {
    setState(() {
      _showSuccessAnimation = true;
    });
    _scanLineController.stop();
    _cornerController.stop();
    widget.onQRScanned(true);
  }

  void _onAnimationComplete() {
    setState(() {
      _showSuccessAnimation = false;
    });
    widget.onClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccessAnimation) {
      return AttendanceSuccessAnimation(
        studentName: widget.studentName,
        courseName: widget.courseName,
        status: DateTime.now().hour > 9 && DateTime.now().minute > 15
            ? 'late'
            : 'present',
        onComplete: _onAnimationComplete,
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'QR Scanner Demo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 28),
          onPressed: widget.onClose,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.white, size: 28),
            onPressed: () {
              // Simulate flash toggle
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Flash toggled'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Simulated camera view with gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey[900]!,
                  Colors.grey[800]!,
                  Colors.grey[900]!,
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Camera View',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '(Demo Mode)',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Enhanced scanning overlay
          _buildScanningOverlay(),

          // Instructions
          _buildInstructions(),

          // Simulate scan button
          _buildSimulateButton(),
        ],
      ),
    );
  }

  Widget _buildScanningOverlay() {
    return Center(
      child: Container(
        width: 280,
        height: 280,
        child: Stack(
          children: [
            // Main border
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            // Animated corners
            ...List.generate(4, (index) => _buildAnimatedCorner(index)),

            // Animated scan line
            AnimatedBuilder(
              animation: _scanLineController,
              builder: (context, child) {
                return Positioned(
                  top: 20 + (240 * _scanLineController.value),
                  left: 20,
                  right: 20,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppTheme.primaryColor,
                          AppTheme.primaryColor,
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Center focus point
            Center(
              child: AnimatedBuilder(
                animation: _cornerController,
                builder: (context, child) {
                  return Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(
                        alpha: 0.3 + (_cornerController.value * 0.4),
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCorner(int index) {
    final positions = [
      {'top': 0.0, 'left': 0.0}, // Top-left
      {'top': 0.0, 'right': 0.0}, // Top-right
      {'bottom': 0.0, 'left': 0.0}, // Bottom-left
      {'bottom': 0.0, 'right': 0.0}, // Bottom-right
    ];

    final pos = positions[index];

    return Positioned(
      top: pos['top'],
      left: pos['left'],
      right: pos['right'],
      bottom: pos['bottom'],
      child: AnimatedBuilder(
        animation: _cornerController,
        builder: (context, child) {
          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border(
                top: index < 2
                    ? BorderSide(
                        color: AppTheme.primaryColor.withValues(
                          alpha: 0.5 + (_cornerController.value * 0.5),
                        ),
                        width: 4,
                      )
                    : BorderSide.none,
                bottom: index >= 2
                    ? BorderSide(
                        color: AppTheme.primaryColor.withValues(
                          alpha: 0.5 + (_cornerController.value * 0.5),
                        ),
                        width: 4,
                      )
                    : BorderSide.none,
                left: index % 2 == 0
                    ? BorderSide(
                        color: AppTheme.primaryColor.withValues(
                          alpha: 0.5 + (_cornerController.value * 0.5),
                        ),
                        width: 4,
                      )
                    : BorderSide.none,
                right: index % 2 == 1
                    ? BorderSide(
                        color: AppTheme.primaryColor.withValues(
                          alpha: 0.5 + (_cornerController.value * 0.5),
                        ),
                        width: 4,
                      )
                    : BorderSide.none,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInstructions() {
    return Positioned(
          bottom: 200,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.qr_code_scanner, color: Colors.white, size: 32)
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 2000.ms, color: AppTheme.primaryColor),

                const SizedBox(height: 12),

                const Text(
                  'Enhanced QR Scanner',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  'Point camera at any QR code or tap simulate',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 500.ms, duration: 800.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildSimulateButton() {
    return Positioned(
          bottom: 80,
          left: 50,
          right: 50,
          child: ElevatedButton.icon(
            onPressed: _onQRScanned,
            icon: const Icon(Icons.qr_code, size: 20),
            label: const Text(
              'Simulate QR Scan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 4,
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 800.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0)
        .shimmer(delay: 2000.ms, duration: 1500.ms);
  }
}
