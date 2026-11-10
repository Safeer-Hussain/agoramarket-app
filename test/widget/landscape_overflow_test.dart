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

  testWidgets('Zero RenderFlex overflow errors on 800x360 landscape viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 360);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
    expect(tester.takeException(), isNull);

    final scaffoldState = tester.state<AdaptiveScaffoldState>(
      find.byType(AdaptiveScaffold),
    );

    // Verify Tab 1 (Map)
    scaffoldState.setDestination(1);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);

    // Verify Tab 2 (Messages 2-pane)
    scaffoldState.setDestination(2);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);

    // Verify Tab 3 (Concierge 2-pane)
    scaffoldState.setDestination(3);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);

    // Verify Tab 4 (Profile with mainAxisExtent: 145 grid)
    scaffoldState.setDestination(4);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);
  });
}
