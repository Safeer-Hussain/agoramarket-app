import 'package:agora_market_app/presentation/map/map_filter_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mocks/mock_repositories.dart';

void main() {
  group('MapFilterProvider Unit Tests', () {
    late MockMarketplaceRepository mockRepo;
    late MapFilterProvider provider;

    setUp(() {
      mockRepo = MockMarketplaceRepository();
      provider = MapFilterProvider(repository: mockRepo);
    });

    test('Initializes with default Lahore center and radius filter', () async {
      await provider.loadMapData();
      expect(provider.filteredPitches.length, 3);
      expect(provider.radiusKm, 25.0);
      expect(provider.selectedCategory, 'All');
    });

    test('Filters listings by category correctly', () async {
      await provider.loadMapData();

      provider.setCategory('Freelancer');
      expect(provider.filteredPitches.length, 2);
      expect(
        provider.filteredPitches.every((p) => p.category == 'Freelancer'),
        true,
      );

      provider.setCategory('Agency');
      expect(provider.filteredPitches.length, 1);
      expect(provider.filteredPitches.first.category, 'Agency');
    });

    test('Filters listings by max hourly rate threshold', () async {
      await provider.loadMapData();

      provider.setMaxHourlyRate(100.0);
      expect(provider.filteredPitches.length, 2);
      expect(
        provider.filteredPitches.every((p) => p.hourlyRate <= 100.0),
        true,
      );
    });

    test('Search query matches title, creator name, and skills', () async {
      await provider.loadMapData();

      provider.setSearchQuery('Kubernetes');
      expect(provider.filteredPitches.length, 1);
      expect(provider.filteredPitches.first.creatorName, 'Bilal Tariq');

      provider.setSearchQuery('Safeer');
      expect(provider.filteredPitches.length, 1);
      expect(provider.filteredPitches.first.creatorName, 'Safeer Hussain');
    });

    test('Computes distance and travel time estimate accurately', () async {
      await provider.loadMapData();
      final pitch = provider.filteredPitches.first;

      final distKm = provider.calculateDistanceTo(pitch);
      expect(distKm, greaterThanOrEqualTo(0.0));

      final estimate = provider.getTravelEstimate(pitch);
      expect(estimate.contains('min drive'), true);
      expect(estimate.contains('km'), true);
    });
  });
}
