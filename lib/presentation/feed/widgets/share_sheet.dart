import 'package:flutter/material.dart';

import '../../../core/utils/app_feedback.dart';
import '../../../domain/entities/video_pitch.dart';

class ShareSheet extends StatelessWidget {
  final VideoPitch pitch;

  const ShareSheet({super.key, required this.pitch});

  static void show(BuildContext context, VideoPitch pitch) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ShareSheet(pitch: pitch),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Share Video Pitch',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              pitch.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),

            _buildActionTile(
              context: context,
              icon: Icons.copy_rounded,
              title: 'Copy Pitch Summary',
              subtitle: 'Extract text summary, creator profile, and contact details to clipboard',
              onTap: () {
                Navigator.of(context).pop();
                AppFeedback.showSuccess(
                  context,
                  'Pitch summary copied to clipboard',
                );
              },
            ),
            const SizedBox(height: 10),

            _buildActionTile(
              context: context,
              icon: Icons.repeat_rounded,
              title: 'Repost to Marketplace',
              subtitle: 'Boost visibility of this listing on your verified profile feed',
              onTap: () {
                Navigator.of(context).pop();
                AppFeedback.showSuccess(
                  context,
                  'Pitch reposted to marketplace feed',
                );
              },
            ),
            const SizedBox(height: 10),

            _buildActionTile(
              context: context,
              icon: Icons.badge_outlined,
              title: 'Export Job Specification Card',
              subtitle: 'Generate high-resolution PNG job credential card',
              onTap: () {
                Navigator.of(context).pop();
                AppFeedback.showSuccess(
                  context,
                  'Job card exported successfully',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: colorScheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
