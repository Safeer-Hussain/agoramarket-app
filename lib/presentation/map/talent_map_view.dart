import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/video_pitch.dart';
import '../navigation/adaptive_scaffold.dart';
import 'map_filter_provider.dart';
import 'widgets/map_filter_sheet.dart';
import 'widgets/map_listing_card.dart';

class TalentMapView extends StatefulWidget {
  const TalentMapView({super.key});

  @override
  State<TalentMapView> createState() => _TalentMapViewState();
}

class _TalentMapViewState extends State<TalentMapView> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToChat() {
    final scaffold = context.findAncestorStateOfType<AdaptiveScaffoldState>();
    if (scaffold != null) {
      scaffold.setDestination(2); // Switch to Messages tab
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Consumer<MapFilterProvider>(
      builder: (context, mapProvider, child) {
        final selected = mapProvider.selectedPitch;

        return Scaffold(
          backgroundColor: colorScheme.surface,
          resizeToAvoidBottomInset: false,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.small(
                heroTag: 'fab_map_filter',
                tooltip: 'Filter map talent and radius',
                backgroundColor: colorScheme.surfaceContainerHighest,
                foregroundColor: colorScheme.onSurface,
                onPressed: () => MapFilterSheet.show(context),
                child: const Icon(Icons.tune_rounded, size: 20),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                heroTag: 'fab_map_recenter',
                tooltip: 'Recenter map to tech hub',
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                onPressed: () {
                  mapProvider.recenterToTechHub();
                  _mapController.move(mapProvider.userLatLng, 13.5);
                },
                child: const Icon(Icons.my_location_rounded),
              ),
              if (!isLandscape && selected != null) const SizedBox(height: 180),
            ],
          ),
          body: isLandscape
              ? _buildLandscapeLayout(context, mapProvider)
              : _buildPortraitLayout(context, mapProvider),
        );
      },
    );
  }

  Widget _buildPortraitLayout(
    BuildContext context,
    MapFilterProvider mapProvider,
  ) {
    final selected = mapProvider.selectedPitch;

    return Stack(
      children: [
        _buildMapWidget(mapProvider),
        _buildSearchBarOverlay(context, mapProvider),
        if (selected != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MapListingCard(
              pitch: selected,
              onMessageDirect: _navigateToChat,
            ),
          ),
      ],
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    MapFilterProvider mapProvider,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final selected = mapProvider.selectedPitch;

    return Row(
      children: [
        // Left Pane: Map Canvas
        Expanded(
          flex: 6,
          child: Stack(
            children: [
              _buildMapWidget(mapProvider),
              _buildSearchBarOverlay(context, mapProvider),
            ],
          ),
        ),

        // Vertical divider
        VerticalDivider(width: 1, color: colorScheme.outlineVariant),

        // Right Pane: Filtered listings master-detail (independent SingleChildScrollView)
        Expanded(
          flex: 4,
          child: Container(
            color: colorScheme.surfaceContainerLowest,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top status bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.hub_outlined,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Nearby Listings (${mapProvider.filteredPitches.length})',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Within ${mapProvider.radiusKm.toStringAsFixed(0)}km',
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Selected Listing Card
                  if (selected != null)
                    MapListingCard(
                      pitch: selected,
                      onMessageDirect: _navigateToChat,
                      margin: const EdgeInsets.only(bottom: 8),
                    ),

                  // Other nearby listings list
                  Text(
                    'All Nearby Matches',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...mapProvider.filteredPitches.map((item) {
                    final isCurrent = item.id == selected?.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: _buildMiniListingTile(
                        context,
                        item,
                        isCurrent,
                        mapProvider,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapWidget(MapFilterProvider mapProvider) {
    final colorScheme = Theme.of(context).colorScheme;
    final selected = mapProvider.selectedPitch;

    final markers = <Marker>[
      // User / Tech Hub Center Pin
      Marker(
        point: mapProvider.userLatLng,
        width: 44,
        height: 44,
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.25),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.surface, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ];

    // Add listing markers
    for (final pitch in mapProvider.filteredPitches) {
      final isSel = selected?.id == pitch.id;
      final Color pinColor = pitch.category == 'Freelancer'
          ? colorScheme.secondary
          : (pitch.category == 'Job'
                ? colorScheme.primary
                : colorScheme.tertiary);

      markers.add(
        Marker(
          point: LatLng(pitch.latitude, pitch.longitude),
          width: isSel ? 52 : 42,
          height: isSel ? 52 : 42,
          child: Semantics(
            button: true,
            label:
                '${pitch.creatorName}, ${pitch.role}, \$${pitch.hourlyRate.toStringAsFixed(0)} per hour in ${pitch.locationName}',
            child: GestureDetector(
              onTap: () {
                mapProvider.selectPitch(pitch);
                _mapController.move(
                  LatLng(pitch.latitude, pitch.longitude),
                  14.0,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  color: isSel ? pinColor : colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSel ? colorScheme.onPrimary : pinColor,
                    width: isSel ? 2.5 : 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.4),
                      blurRadius: isSel ? 12 : 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: CircleAvatar(
                    radius: isSel ? 18 : 14,
                    backgroundColor: colorScheme.surfaceContainer,
                    backgroundImage: AssetImage(pitch.creatorAvatar),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Polyline route if enabled
    final polylines = <Polyline>[];
    if (mapProvider.showRoute && selected != null) {
      polylines.add(
        Polyline(
          points: [
            mapProvider.userLatLng,
            LatLng(selected.latitude, selected.longitude),
          ],
          strokeWidth: 4.0,
          color: colorScheme.primary,
        ),
      );
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: mapProvider.userLatLng,
        initialZoom: 13.0,
        minZoom: 4.0,
        maxZoom: 18.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.agoramarket.app',
        ),
        if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
        MarkerLayer(markers: markers),
      ],
    );
  }

  Widget _buildSearchBarOverlay(
    BuildContext context,
    MapFilterProvider mapProvider,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Positioned(
      top: 48,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant, width: 1),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 14),
                child: Icon(
                  Icons.search_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search roles, skills, or Lahore hub...',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (q) => mapProvider.setSearchQuery(q),
                ),
              ),
              if (_searchController.text.isNotEmpty)
                IconButton(
                  tooltip: 'Clear search query',
                  icon: Icon(
                    Icons.clear_rounded,
                    size: 18,
                    color: colorScheme.outline,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    mapProvider.setSearchQuery('');
                  },
                ),
              IconButton(
                tooltip: 'Open map filter and radius settings',
                icon: Icon(
                  Icons.tune_rounded,
                  size: 20,
                  color: colorScheme.onSurface,
                ),
                onPressed: () => MapFilterSheet.show(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniListingTile(
    BuildContext context,
    VideoPitch pitch,
    bool isSelected,
    MapFilterProvider mapProvider,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        mapProvider.selectPitch(pitch);
        _mapController.move(LatLng(pitch.latitude, pitch.longitude), 14.0);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.surfaceContainerHigh
              : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: colorScheme.surfaceContainerHighest,
              backgroundImage: AssetImage(pitch.creatorAvatar),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pitch.creatorName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    pitch.role,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '\$${pitch.hourlyRate.toStringAsFixed(0)}/hr',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
