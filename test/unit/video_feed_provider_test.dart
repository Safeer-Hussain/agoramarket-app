import 'package:agora_market_app/presentation/feed/video_feed_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mocks/mock_repositories.dart';

void main() {
  group('VideoFeedProvider Unit Tests', () {
    late MockMarketplaceRepository mockRepo;
    late VideoFeedProvider provider;

    setUp(() {
      mockRepo = MockMarketplaceRepository();
      provider = VideoFeedProvider(repository: mockRepo);
    });

    test('Loads initial pitches on initialization', () async {
      await provider.loadPitches();
      expect(provider.pitches.length, 3);
      expect(provider.pitches.first.creatorName, 'Safeer Hussain');
    });

    test(
      'toggleLike reacts immediately and updates counter correctly',
      () async {
        await provider.loadPitches();
        final initialPitch = provider.pitches.first;
        final initialLikes = initialPitch.likesCount;
        expect(initialPitch.isLiked, false);

        await provider.toggleLike(initialPitch.id);
        expect(provider.pitches.first.isLiked, true);
        expect(provider.pitches.first.likesCount, initialLikes + 1);

        await provider.toggleLike(initialPitch.id);
        expect(provider.pitches.first.isLiked, false);
        expect(provider.pitches.first.likesCount, initialLikes);
      },
    );

    test(
      'toggleBookmark reacts immediately and updates counter correctly',
      () async {
        await provider.loadPitches();
        final initialPitch = provider.pitches.first;
        final initialBookmarks = initialPitch.bookmarksCount;
        expect(initialPitch.isBookmarked, false);

        await provider.toggleBookmark(initialPitch.id);
        expect(provider.pitches.first.isBookmarked, true);
        expect(provider.pitches.first.bookmarksCount, initialBookmarks + 1);

        await provider.toggleBookmark(initialPitch.id);
        expect(provider.pitches.first.isBookmarked, false);
        expect(provider.pitches.first.bookmarksCount, initialBookmarks);
      },
    );

    test('createVideoPitch prepends new pitch to beginning of feed', () async {
      await provider.loadPitches();
      final initialCount = provider.pitches.length;

      await provider.createVideoPitch(
        title: 'New High Throughput Stream Engine',
        role: 'Staff Flutter Engineer',
        hourlyRate: 120.0,
        currency: 'USD',
        locationName: 'Gulberg III, Lahore',
        category: 'Freelancer',
        pitchScript: 'Validating end-to-end multi-feed pipelines.',
        skills: ['Flutter', 'WebSockets'],
      );

      expect(provider.pitches.length, initialCount + 1);
      expect(provider.pitches.first.title, 'New High Throughput Stream Engine');
      expect(provider.currentIndex, 0);
    });

    test('addComment updates comments cache for the active pitch', () async {
      await provider.loadPitches();
      const pitchId = 'pitch_test_01';

      await provider.loadComments(pitchId);
      final initialCount = provider.getCommentsForPitch(pitchId).length;

      await provider.addComment(pitchId, 'Great architecture breakdown!');
      final updatedComments = provider.getCommentsForPitch(pitchId);

      expect(updatedComments.length, initialCount + 1);
      expect(updatedComments.first.content, 'Great architecture breakdown!');
    });
  });
}
