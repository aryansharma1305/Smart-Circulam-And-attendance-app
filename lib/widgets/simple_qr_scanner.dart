import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import 'attendance_success_animation.dart';
import 'demo_qr_scanner.dart';

class SimpleQRScanner extends StatefulWidget {
  final String expectedSessionId;
  final String studentName;
  final String courseName;
  final Function(bool) onQRScanned;
  final VoidCallback? onClose;

  const SimpleQRScanner({
    super.key,
    required this.expectedSessionId,
    required this.studentName,
    required this.courseName,
    required this.onQRScanned,
    this.onClose,
  });

  @override
  State<SimpleQRScanner> createState() => _SimpleQRScannerState();
}

class _SimpleQRScannerState extends State<SimpleQRScanner>
    with TickerProviderStateMixin {
  bool _showSuccessAnimation = false;
  late AnimationController _scanLineController;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    super.dispose();
  }

  void _handleQRScanned(String qrData) {
    // Simulate QR validation - accept any QR code for demo
    final isValid = qrData.isNotEmpty;

    if (isValid) {
      setState(() {
        _showSuccessAnimation = true;
      });

      // Call the callback after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onQRScanned(true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: widget.onClose ?? () => Navigator.pop(context),
        ),
        title: Text('Scan QR Code', style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          // QR Scanner (using demo scanner)
          DemoQRScanner(
            expectedSessionId: widget.expectedSessionId,
            studentName: widget.studentName,
            courseName: widget.courseName,
            onQRScanned: (success) =>
                _handleQRScanned(success ? 'valid_qr' : ''),
          ),

          // Success Animation Overlay
          if (_showSuccessAnimation)
            AttendanceSuccessAnimation(
              studentName: widget.studentName,
              courseName: widget.courseName,
              status: 'Present',
              onComplete: () {
                setState(() {
                  _showSuccessAnimation = false;
                });
                if (widget.onClose != null) {
                  widget.onClose!();
                } else {
                  Navigator.pop(context);
                }
              },
            ),
        ],
      ),
    );
  }
}
