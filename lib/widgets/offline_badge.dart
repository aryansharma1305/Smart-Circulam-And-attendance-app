import 'package:flutter/material.dart';
import '../core/theme.dart';

class OfflineBadge extends StatelessWidget {
  final bool isOffline;
  final int? queuedActions;
  final VoidCallback? onTap;

  const OfflineBadge({
    super.key,
    required this.isOffline,
    this.queuedActions,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOffline && (queuedActions == null || queuedActions == 0)) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isOffline ? Colors.orange : AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOffline ? Icons.cloud_off : Icons.sync,
              size: 14,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              isOffline ? 'Offline' : '${queuedActions ?? 0} queued',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

