import 'package:agora_market_app/core/performance/render_latency_monitor.dart';
import 'package:agora_market_app/core/theme/app_theme.dart';
import 'package:agora_market_app/core/theme/theme_provider.dart';
import 'package:agora_market_app/presentation/chat/chat_provider.dart';
import 'package:agora_market_app/presentation/concierge/ai_concierge_provider.dart';
import 'package:agora_market_app/presentation/feed/video_feed_provider.dart';
import 'package:agora_market_app/presentation/map/map_filter_provider.dart';
import 'package:agora_market_app/presentation/navigation/adaptive_scaffold.dart';
import 'package:agora_market_app/presentation/profile/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mocks/mock_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Zero duplicate Hero tag exceptions across multi-tab shell', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final mockMarketplace = MockMarketplaceRepository();
    final mockChat = MockChatRepository();
    final mockProfile = MockProfileRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider(prefs: prefs)),
          ChangeNotifierProvider(create: (_) => RenderLatencyMonitor()),
          ChangeNotifierProvider(
            create: (_) => VideoFeedProvider(repository: mockMarketplace),
          ),
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
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const AdaptiveScaffold(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify Tab 0 (Feed) renders without Hero exception
    expect(find.byType(AdaptiveScaffold), findsOneWidget);

    // Switch to Tab 1 (Map)
    final scaffoldState = tester.state<AdaptiveScaffoldState>(
      find.byType(AdaptiveScaffold),
    );
    scaffoldState.setDestination(1);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Switch to Tab 2 (Messages)
    scaffoldState.setDestination(2);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Switch to Tab 3 (Concierge)
    scaffoldState.setDestination(3);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Switch to Tab 4 (Profile)
    scaffoldState.setDestination(4);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Ensure all tabs transitioned with 0 duplicate Hero collisions
    expect(tester.takeException(), isNull);
  });
}
