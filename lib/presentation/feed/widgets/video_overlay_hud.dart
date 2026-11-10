import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/video_pitch.dart';
import '../video_feed_provider.dart';
import 'comment_sheet.dart';
import 'share_sheet.dart';
import 'hire_modal.dart';

class VideoOverlayHud extends StatelessWidget {
  final VideoPitch pitch;

  const VideoOverlayHud({super.key, required this.pitch});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final feedProvider = Provider.of<VideoFeedProvider>(context);

    return Positioned(
      left: 16,
      right: 16,
      bottom: 24,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Left Column: Pitch details & creator bio
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Creator & verified badge
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      backgroundImage: AssetImage(pitch.creatorAvatar),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              pitch.creatorName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                shadows: [
                                  Shadow(
                                    color: colorScheme.shadow.withValues(
                                      alpha: 0.6,
                                    ),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        pitch.category,
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Title
                Text(
                  pitch.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.25,
                    shadows: [
                      Shadow(
                        color: colorScheme.shadow.withValues(alpha: 0.7),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Hourly rate badge & Location
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.8,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.payments_outlined,
                            size: 12,
                            color: colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '\$${pitch.hourlyRate.toStringAsFixed(0)}/hr',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.8,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            pitch.locationName,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Skill Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: pitch.skills.take(3).map((s) {
                      return Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHigh.withValues(
                            alpha: 0.7,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          s,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Right Column: Vertical Action Buttons
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Like Button
              _ActionButton(
                icon: pitch.isLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_outline_rounded,
                iconColor: pitch.isLiked
                    ? colorScheme.error
                    : colorScheme.onSurface,
                label: pitch.likesCount.toString(),
                semanticLabel: pitch.isLiked
                    ? 'Unlike pitch. Current likes: ${pitch.likesCount}'
                    : 'Like pitch. Current likes: ${pitch.likesCount}',
                onTap: () => feedProvider.toggleLike(pitch.id),
              ),
              const SizedBox(height: 14),

              // Bookmark Button
              _ActionButton(
                icon: pitch.isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_outline_rounded,
                iconColor: pitch.isBookmarked
                    ? colorScheme.tertiary
                    : colorScheme.onSurface,
                label: pitch.bookmarksCount.toString(),
                semanticLabel: pitch.isBookmarked
                    ? 'Remove bookmark. Current bookmarks: ${pitch.bookmarksCount}'
                    : 'Bookmark pitch. Current bookmarks: ${pitch.bookmarksCount}',
                onTap: () => feedProvider.toggleBookmark(pitch.id),
              ),
              const SizedBox(height: 14),

              // Comments Button
              _ActionButton(
                icon: Icons.chat_bubble_outline_rounded,
                iconColor: colorScheme.onSurface,
                label: 'Discuss',
                semanticLabel: 'Open discussion comments for ${pitch.title}',
                onTap: () => CommentSheet.show(context, pitch.id),
              ),
              const SizedBox(height: 14),

              // Share Button
              _ActionButton(
                icon: Icons.share_outlined,
                iconColor: colorScheme.onSurface,
                label: 'Share',
                semanticLabel: 'Share pitch: ${pitch.title}',
                onTap: () => ShareSheet.show(context, pitch),
              ),
              const SizedBox(height: 14),

              // Hire / Apply CTA
              Semantics(
                button: true,
                label: 'Hire specialist ${pitch.creatorName}',
                child: InkWell(
                  onTap: () => HireModal.show(context, pitch),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.handshake_outlined,
                          size: 14,
                          color: colorScheme.onPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Hire',
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;
  final String? semanticLabel;

  const _ActionButton({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.7,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Icon(icon, size: 22, color: iconColor),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      color: colorScheme.shadow.withValues(alpha: 0.7),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
