import 'package:agora_market_app/core/performance/render_latency_monitor.dart';
import 'package:agora_market_app/core/theme/app_theme.dart';
import 'package:agora_market_app/core/theme/theme_provider.dart';
import 'package:agora_market_app/presentation/chat/chat_provider.dart';
import 'package:agora_market_app/presentation/concierge/ai_concierge_provider.dart';
import 'package:agora_market_app/presentation/feed/video_feed_provider.dart';
import 'package:agora_market_app/presentation/feed/video_feed_view.dart';
import 'package:agora_market_app/presentation/map/map_filter_provider.dart';
import 'package:agora_market_app/presentation/profile/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mocks/mock_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Instant Dark/Light theme switching and reactive feed updates', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final mockMarketplace = MockMarketplaceRepository();
    final mockChat = MockChatRepository();
    final mockProfile = MockProfileRepository();
    final themeProvider = ThemeProvider(prefs: prefs);
    final feedProvider = VideoFeedProvider(repository: mockMarketplace);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: themeProvider),
          ChangeNotifierProvider(create: (_) => RenderLatencyMonitor()),
          ChangeNotifierProvider.value(value: feedProvider),
          ChangeNotifierProvider(
            create: (_) => MapFilterProvider(repository: mockMarketplace),
          ),
          ChangeNotifierProvider(
            create: (_) => ChatProvider(repository: mockChat),
          ),
          ChangeNotifierProvider(create: (_) => AiConciergeProvider()),
          ChangeNotifierProvider(
            create: (_) => ProfileProvider(
              profileRepository: mockProfile,
              marketplaceRepository: mockMarketplace,
              prefs: prefs,
            ),
          ),
        ],
        child: Consumer<ThemeProvider>(
          builder: (context, theme, child) {
            return MaterialApp(
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: theme.themeMode,
              home: const Scaffold(body: VideoFeedView()),
            );
          },
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // 1. Verify Dark Mode initial state
    expect(themeProvider.themeMode, ThemeMode.dark);

    // 2. Toggle Theme to Light Mode
    await themeProvider.toggleTheme();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(themeProvider.themeMode, ThemeMode.light);

    // 3. Reactive Feed Like mutation
    final initialLikes = feedProvider.pitches.first.likesCount;
    expect(find.text(initialLikes.toString()), findsOneWidget);

    // Tap Like icon
    await tester.tap(find.byIcon(Icons.favorite_outline_rounded).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Counter immediately increments in UI
    expect(feedProvider.pitches.first.isLiked, true);
    expect(feedProvider.pitches.first.likesCount, initialLikes + 1);
    expect(find.text((initialLikes + 1).toString()), findsOneWidget);
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
  });
}
