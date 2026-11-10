import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../map_filter_provider.dart';

class MapFilterSheet extends StatelessWidget {
  const MapFilterSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const MapFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mapProvider = Provider.of<MapFilterProvider>(context);

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spatial & Rate Filters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    mapProvider.setRadiusKm(25.0);
                    mapProvider.setMaxHourlyRate(150.0);
                    mapProvider.setCategory('All');
                  },
                  child: Text(
                    'Reset All',
                    style: TextStyle(color: colorScheme.primary, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Category Chips
            Text(
              'Marketplace Role Category',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['All', 'Freelancer', 'Job', 'Agency'].map((cat) {
                final isSelected = mapProvider.selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: colorScheme.primaryContainer,
                  backgroundColor: colorScheme.surfaceContainerHigh,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => mapProvider.setCategory(cat),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Radius Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Search Radius',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${mapProvider.radiusKm.toStringAsFixed(0)} km',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            Slider(
              value: mapProvider.radiusKm,
              min: 1.0,
              max: 50.0,
              activeColor: colorScheme.primary,
              inactiveColor: colorScheme.surfaceContainerHighest,
              onChanged: (v) => mapProvider.setRadiusKm(v),
            ),
            const SizedBox(height: 12),

            // Max Rate Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Max Hourly Rate',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '\$${mapProvider.maxHourlyRate.toStringAsFixed(0)} / hr',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            ),
            Slider(
              value: mapProvider.maxHourlyRate,
              min: 20.0,
              max: 200.0,
              activeColor: colorScheme.secondary,
              inactiveColor: colorScheme.surfaceContainerHighest,
              onChanged: (v) => mapProvider.setMaxHourlyRate(v),
            ),
            const SizedBox(height: 16),

            // Tech Hub Presets
            Text(
              'Switch Tech Hub Anchor',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _HubPresetButton(
                  title: 'Gulberg Tech Core',
                  lat: 31.5204,
                  lng: 74.3587,
                  onTap: () =>
                      mapProvider.recenterToTechHub(lat: 31.5204, lng: 74.3587),
                ),
                _HubPresetButton(
                  title: 'DHA Phase 5 Innovation',
                  lat: 31.4697,
                  lng: 74.4084,
                  onTap: () =>
                      mapProvider.recenterToTechHub(lat: 31.4697, lng: 74.4084),
                ),
                _HubPresetButton(
                  title: 'Arfa Software Park',
                  lat: 31.4759,
                  lng: 74.3414,
                  onTap: () =>
                      mapProvider.recenterToTechHub(lat: 31.4759, lng: 74.3414),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HubPresetButton extends StatelessWidget {
  final String title;
  final double lat;
  final double lng;
  final VoidCallback onTap;

  const _HubPresetButton({
    required this.title,
    required this.lat,
    required this.lng,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ActionChip(
      avatar: Icon(
        Icons.location_city_rounded,
        size: 14,
        color: colorScheme.primary,
      ),
      label: Text(
        title,
        style: TextStyle(fontSize: 11, color: colorScheme.onSurface),
      ),
      backgroundColor: colorScheme.surfaceContainerHigh,
      side: BorderSide(color: colorScheme.outlineVariant),
      onPressed: onTap,
    );
  }
}
