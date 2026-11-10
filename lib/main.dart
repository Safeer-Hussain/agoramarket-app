import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/di/injection_container.dart';
import 'core/performance/render_latency_monitor.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'presentation/chat/chat_provider.dart';
import 'presentation/concierge/ai_concierge_provider.dart';
import 'presentation/feed/video_feed_provider.dart';
import 'presentation/map/map_filter_provider.dart';
import 'presentation/profile/profile_provider.dart';
import 'presentation/splash/splash_view.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        debugPrint('FlutterError caught: ${details.exceptionAsString()}');
      };

      try {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
          ),
        );
      } catch (e) {
        debugPrint('SystemChrome initialization notice: $e');
      }

      SharedPreferences? prefs;
      try {
        await initDependencies();
        if (sl.isRegistered<SharedPreferences>()) {
          prefs = sl<SharedPreferences>();
        }
      } catch (e, stack) {
        debugPrint('Dependency initialization notice: $e\n$stack');
      }

      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider(prefs: prefs)),
            ChangeNotifierProvider.value(
              value: sl.isRegistered<RenderLatencyMonitor>()
                  ? sl<RenderLatencyMonitor>()
                  : RenderLatencyMonitor(),
            ),
            ChangeNotifierProvider(
              create: (_) => VideoFeedProvider(repository: sl()),
            ),
            ChangeNotifierProvider(
              create: (_) => MapFilterProvider(repository: sl()),
            ),
            ChangeNotifierProvider(
              create: (_) => ChatProvider(repository: sl()),
            ),
            ChangeNotifierProvider(
              create: (_) => AiConciergeProvider(database: sl()),
            ),
            ChangeNotifierProvider(
              create: (_) => ProfileProvider(
                profileRepository: sl(),
                marketplaceRepository: sl(),
                prefs: prefs,
              ),
            ),
          ],
          child: const AgoraMarketApp(),
        ),
      );
    },
    (error, stackTrace) {
      debugPrint('Uncaught asynchronous zone error: $error\n$stackTrace');
    },
  );
}

class AgoraMarketApp extends StatelessWidget {
  const AgoraMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'AgoraMarket',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const SplashView(),
        );
      },
    );
  }
}
