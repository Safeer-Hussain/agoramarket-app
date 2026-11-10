import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/performance/render_latency_monitor.dart';

class LatencyHudPill extends StatelessWidget {
  const LatencyHudPill({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<RenderLatencyMonitor>(
      builder: (context, monitor, _) {
        if (!monitor.showHudPill) {
          return const SizedBox.shrink();
        }

        final ms = monitor.averageMs;
        final isSub8ms = ms < 8.0;

        return Positioned(
          top: 48,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.85,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSub8ms ? colorScheme.primary : colorScheme.tertiary,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isSub8ms
                          ? colorScheme.primary
                          : colorScheme.tertiary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${ms.toStringAsFixed(1)}ms UI Frame',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isSub8ms ? '120fps' : '60fps',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
