import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/video_pitch.dart';
import '../../feed/widgets/hire_modal.dart';
import '../map_filter_provider.dart';

class MapListingCard extends StatelessWidget {
  final VideoPitch pitch;
  final VoidCallback onMessageDirect;
  final EdgeInsetsGeometry? margin;

  const MapListingCard({
    super.key,
    required this.pitch,
    required this.onMessageDirect,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mapProvider = Provider.of<MapFilterProvider>(context);
    final travelEstimate = mapProvider.getTravelEstimate(pitch);

    return Container(
      margin:
          margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colorScheme.surfaceContainerHighest,
                backgroundImage: AssetImage(pitch.creatorAvatar),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  pitch.creatorName,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.verified_rounded,
                                size: 15,
                                color: colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
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
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      pitch.role,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            pitch.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),

          // Distance & travel time badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.navigation_rounded,
                  size: 14,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    travelEstimate,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Text(
                  '\$${pitch.hourlyRate.toStringAsFixed(0)}/hr',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Actions Row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: onMessageDirect,
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                label: const Text(
                  'Message Direct',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.onSurface,
                  side: BorderSide(
                    color: mapProvider.showRoute
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                  ),
                  backgroundColor: mapProvider.showRoute
                      ? colorScheme.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => mapProvider.toggleRoute(),
                icon: Icon(
                  mapProvider.showRoute
                      ? Icons.route_rounded
                      : Icons.alt_route_rounded,
                  size: 16,
                  color: mapProvider.showRoute
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
                label: Text(
                  mapProvider.showRoute ? 'Route Active' : 'Pin Route',
                  style: TextStyle(
                    fontSize: 12,
                    color: mapProvider.showRoute
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                ),
              ),
              IconButton.filledTonal(
                icon: const Icon(Icons.handshake_outlined, size: 18),
                onPressed: () => HireModal.show(context, pitch),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
