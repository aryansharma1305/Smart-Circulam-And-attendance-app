import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'dart:math';

class StartSessionPage extends StatefulWidget {
  final Map<String, dynamic> classData;

  const StartSessionPage({super.key, required this.classData});

  @override
  State<StartSessionPage> createState() => _StartSessionPageState();
}

class _StartSessionPageState extends State<StartSessionPage> {
  bool _sessionActive = false;
  String _qrCode = 'DEMO_QR_123456';
  int _presentCount = 0;
  int _lateCount = 0;
  final int _totalEnrolled = 25;
  Timer? _qrTimer;
  int _qrRotationCounter = 0;

  String _generateQRCode() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sessionId =
        widget.classData['subject']?.replaceAll(' ', '_') ?? 'session';
    final randomCode = random.nextInt(999999).toString().padLeft(6, '0');

    return '${sessionId}_${timestamp}_$randomCode';
  }

  void _startQRRotation() {
    _qrTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_sessionActive) {
        setState(() {
          _qrCode = _generateQRCode();
          _qrRotationCounter++;
        });
      }
    });
  }

  void _stopQRRotation() {
    _qrTimer?.cancel();
    _qrTimer = null;
  }

  void _startSession() {
    setState(() {
      _sessionActive = true;
      _presentCount = 18;
      _lateCount = 3;
      _qrCode = _generateQRCode(); // Generate initial QR code
    });

    _startQRRotation(); // Start rotating QR codes every 30 seconds
  }

  void _endSession() {
    _stopQRRotation(); // Stop QR rotation

    setState(() {
      _sessionActive = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Session ended successfully')));

    context.pop();
  }

  @override
  void dispose() {
    _stopQRRotation(); // Clean up timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.classData['subject']} Session'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Class Information',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text('Subject: ${widget.classData['subject']}'),
                    Text('Time: ${widget.classData['time']}'),
                    Text('Room: ${widget.classData['room']}'),
                    Text('Total Enrolled: $_totalEnrolled'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (!_sessionActive) ...[
              ElevatedButton(
                onPressed: _startSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text(
                  'Start Session',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ] else ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Session Active',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: Colors.green),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.blue.shade50,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(
                                  Icons.qr_code,
                                  size: 120,
                                  color: Colors.blue,
                                ),
                                if (_qrRotationCounter > 0)
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.refresh,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _qrCode,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rotates every 30s (#${_qrRotationCounter + 1})',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                '$_presentCount',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const Text('Present'),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                '$_lateCount',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                              const Text('Late'),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                '${_totalEnrolled - _presentCount - _lateCount}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const Text('Absent'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.push(
                          '/teacher/roster',
                          extra: widget.classData,
                        );
                      },
                      child: const Text('View Roster'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.push(
                          '/teacher/attendance-display',
                          extra: widget.classData,
                        );
                      },
                      child: const Text('Attendance Display'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _endSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text(
                  'End Session',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
