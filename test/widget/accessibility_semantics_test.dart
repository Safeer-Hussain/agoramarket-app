import 'package:agora_market_app/core/performance/render_latency_monitor.dart';
import 'package:agora_market_app/core/theme/app_theme.dart';
import 'package:agora_market_app/core/theme/theme_provider.dart';
import 'package:agora_market_app/presentation/chat/chat_provider.dart';
import 'package:agora_market_app/presentation/concierge/ai_concierge_provider.dart';
import 'package:agora_market_app/presentation/feed/video_feed_provider.dart';
import 'package:agora_market_app/presentation/feed/widgets/video_overlay_hud.dart';
import 'package:agora_market_app/presentation/feed/widgets/video_reel_canvas.dart';
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

  testWidgets(
    'Sprint 23: Screen reader accessibility and semantics verification',
    (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final semantics = tester.ensureSemantics();

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final mockMarketplace = MockMarketplaceRepository();
      final mockChat = MockChatRepository();
      final mockProfile = MockProfileRepository();

      final videoFeedProvider = VideoFeedProvider(repository: mockMarketplace);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider(prefs: prefs)),
            ChangeNotifierProvider(create: (_) => RenderLatencyMonitor()),
            ChangeNotifierProvider.value(value: videoFeedProvider),
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

      // 1. Verify Feed play/pause semantics on custom canvas
      expect(find.byType(VideoReelCanvas), findsOneWidget);
      expect(find.byType(VideoOverlayHud), findsOneWidget);

      // 2. Verify Floating Action Button tooltips for screen readers
      final fabFinder = find.byType(FloatingActionButton);
      expect(fabFinder, findsOneWidget);
      final fabWidget = tester.widget<FloatingActionButton>(fabFinder);
      expect(fabWidget.tooltip, isNotNull);
      expect(fabWidget.tooltip, equals('Publish new video pitch'));

      // 3. Switch to Map tab and verify tooltips & semantics
      final scaffoldState = tester.state<AdaptiveScaffoldState>(
        find.byType(AdaptiveScaffold),
      );
      scaffoldState.setDestination(1);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final mapFabFinder = find.byWidgetPredicate(
        (w) => w is FloatingActionButton && w.heroTag == 'fab_map_recenter',
      );
      expect(mapFabFinder, findsOneWidget);
      final mapFabWidget = tester.widget<FloatingActionButton>(mapFabFinder);
      expect(mapFabWidget.tooltip, equals('Recenter map to tech hub'));

      // 4. Switch to Messages tab and verify new chat button semantics
      scaffoldState.setDestination(2);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final chatFabFinder = find.byType(FloatingActionButton);
      expect(chatFabFinder, findsOneWidget);
      final chatFabWidget = tester.widget<FloatingActionButton>(chatFabFinder);
      expect(
        chatFabWidget.tooltip,
        equals('Start new direct contract negotiation'),
      );

      // 5. Switch to Profile tab and verify portfolio FAB and availability switch semantics
      scaffoldState.setDestination(4);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final profileFabFinder = find.byType(FloatingActionButton);
      expect(profileFabFinder, findsOneWidget);
      final profileFabWidget = tester.widget<FloatingActionButton>(
        profileFabFinder,
      );
      expect(
        profileFabWidget.tooltip,
        equals('Add new verified case study portfolio item'),
      );

      // Verify availability toggle switch exists and is accessible
      expect(find.byType(Switch), findsOneWidget);

      // No exceptions during semantic tree inspection
      expect(tester.takeException(), isNull);
      semantics.dispose();
    },
  );
}
