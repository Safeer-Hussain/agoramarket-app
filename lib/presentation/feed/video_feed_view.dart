import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'video_feed_provider.dart';
import 'widgets/video_reel_canvas.dart';
import 'widgets/video_overlay_hud.dart';
import 'widgets/publish_pitch_modal.dart';
import 'widgets/hire_modal.dart';
import 'widgets/comment_sheet.dart';
import 'widgets/share_sheet.dart';

class VideoFeedView extends StatefulWidget {
  const VideoFeedView({super.key});

  @override
  State<VideoFeedView> createState() => _VideoFeedViewState();
}

class _VideoFeedViewState extends State<VideoFeedView> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Consumer<VideoFeedProvider>(
      builder: (context, feedProvider, child) {
        if (feedProvider.isLoading && feedProvider.pitches.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        }

        if (feedProvider.pitches.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.video_library_outlined,
                  size: 48,
                  color: colorScheme.outline,
                ),
                const SizedBox(height: 12),
                Text(
                  'No video pitches loaded.',
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => feedProvider.loadPitches(),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Reload Feed'),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: colorScheme.surface,
          floatingActionButton: FloatingActionButton(
            heroTag: 'fab_video_pitch_create',
            tooltip: 'Publish new video pitch',
            mini: isLandscape,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            onPressed: () => PublishPitchModal.show(context),
            child: const Icon(Icons.add_rounded),
          ),
          body: isLandscape
              ? _buildLandscapeLayout(context, feedProvider)
              : _buildPortraitLayout(context, feedProvider),
        );
      },
    );
  }

  Widget _buildPortraitLayout(
    BuildContext context,
    VideoFeedProvider feedProvider,
  ) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: feedProvider.pitches.length,
      onPageChanged: (index) {
        feedProvider.setIndex(index);
      },
      itemBuilder: (context, index) {
        final pitch = feedProvider.pitches[index];
        return Stack(
          fit: StackFit.expand,
          children: [
            VideoReelCanvas(
              pitch: pitch,
              isSelected: feedProvider.currentIndex == index,
            ),
            VideoOverlayHud(pitch: pitch),
          ],
        );
      },
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    VideoFeedProvider feedProvider,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final pitch = feedProvider.currentPitch ?? feedProvider.pitches.first;

    return Row(
      children: [
        // Left Pane: Video player
        Expanded(
          flex: 5,
          child: Container(
            color: colorScheme.surfaceContainerLowest,
            child: Stack(
              fit: StackFit.expand,
              children: [
                VideoReelCanvas(pitch: pitch, isSelected: true),
                Positioned(
                  bottom: 8,
                  left: 12,
                  right: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton.filledTonal(
                        icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                        onPressed: feedProvider.currentIndex > 0
                            ? () => feedProvider.setIndex(
                                feedProvider.currentIndex - 1,
                              )
                            : null,
                      ),
                      Text(
                        '${feedProvider.currentIndex + 1} / ${feedProvider.pitches.length}',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton.filledTonal(
                        icon: const Icon(
                          Icons.arrow_downward_rounded,
                          size: 18,
                        ),
                        onPressed:
                            feedProvider.currentIndex <
                                feedProvider.pitches.length - 1
                            ? () => feedProvider.setIndex(
                                feedProvider.currentIndex + 1,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Vertical divider
        VerticalDivider(width: 1, color: colorScheme.outlineVariant),

        // Right Pane: Job specification & details (independent SingleChildScrollView)
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header badge row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      backgroundImage: AssetImage(pitch.creatorAvatar),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  pitch.creatorName,
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
                          Text(
                            pitch.role,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
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
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        pitch.category,
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Title
                Text(
                  pitch.title,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),

                // Rate & Location (Wrap for guaranteed zero-overflow safety)
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Text(
                        '\$${pitch.hourlyRate.toStringAsFixed(0)}/hr',
                        style: TextStyle(
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colorScheme.outlineVariant),
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Technical Pitch Script
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Technical Value Proposition',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pitch.pitchScript,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Skills
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: pitch.skills.map((s) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                // Interactive CTA Action Row (Wrap to avoid horizontal edge overflow)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                      onPressed: () => HireModal.show(context, pitch),
                      icon: const Icon(Icons.handshake_outlined, size: 16),
                      label: const Text('Hire Specialist'),
                    ),
                    FilledButton.tonalIcon(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      ),
                      icon: Icon(
                        pitch.isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline_rounded,
                        color: pitch.isLiked
                            ? colorScheme.error
                            : colorScheme.onSurface,
                        size: 18,
                      ),
                      label: Text('${pitch.likesCount}'),
                      onPressed: () => feedProvider.toggleLike(pitch.id),
                    ),
                    IconButton.filledTonal(
                      icon: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 18,
                      ),
                      onPressed: () => CommentSheet.show(context, pitch.id),
                    ),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.share_outlined, size: 18),
                      onPressed: () => ShareSheet.show(context, pitch),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
