import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../chat/chat_inbox_view.dart';
import '../chat/chat_provider.dart';
import '../common/latency_hud_pill.dart';
import '../concierge/ai_concierge_view.dart';
import '../feed/video_feed_view.dart';
import '../map/talent_map_view.dart';
import '../profile/user_profile_view.dart';

class AdaptiveScaffold extends StatefulWidget {
  const AdaptiveScaffold({super.key});

  @override
  State<AdaptiveScaffold> createState() => AdaptiveScaffoldState();
}

class AdaptiveScaffoldState extends State<AdaptiveScaffold> {
  int _currentIndex = 0;
  bool _isOffline = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  final List<Widget> _destinations = const [
    VideoFeedView(),
    TalentMapView(),
    ChatInboxView(),
    AiMatchConciergeView(),
    UserProfileView(),
  ];

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final isDisconnected =
          results.isEmpty || results.every((r) => r == ConnectivityResult.none);
      if (_isOffline != isDisconnected && mounted) {
        setState(() {
          _isOffline = isDisconnected;
        });
      }
    });
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final results = await Connectivity().checkConnectivity();
      final isDisconnected =
          results.isEmpty || results.every((r) => r == ConnectivityResult.none);
      if (mounted) {
        setState(() {
          _isOffline = isDisconnected;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  void setDestination(int index) {
    if (index >= 0 && index < _destinations.length) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final chatProvider = Provider.of<ChatProvider>(context);
    final totalUnread = chatProvider.conversations.fold<int>(
      0,
      (sum, c) => sum + c.unreadCount,
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: Stack(
          children: [
            Column(
              children: [
                // Animated Offline banner
                if (_isOffline)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    color: colorScheme.errorContainer,
                    child: SafeArea(
                      bottom: false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_off_rounded, size: 14, color: colorScheme.onErrorContainer),
                          const SizedBox(width: 8),
                          Text(
                            'Offline Mode - Serving Cached Marketplace Feed & Messages',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onErrorContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Main navigation layout
                Expanded(
                  child: isLandscape
                      ? Row(
                          children: [
                            // Landscape NavigationRail (360dp height safe with IntrinsicHeight & scrollable)
                            SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              child: IntrinsicHeight(
                                child: NavigationRail(
                                  selectedIndex: _currentIndex,
                                  minWidth: 56,
                                  labelType: NavigationRailLabelType.none,
                                  backgroundColor: colorScheme.surfaceContainer,
                                  indicatorColor: colorScheme.primaryContainer,
                                  onDestinationSelected: setDestination,
                                  destinations: [
                                    const NavigationRailDestination(
                                      icon: Icon(Icons.play_circle_outline_rounded, size: 20),
                                      selectedIcon: Icon(Icons.play_circle_rounded, size: 20),
                                      label: Text('Feed'),
                                    ),
                                    const NavigationRailDestination(
                                      icon: Icon(Icons.map_outlined, size: 20),
                                      selectedIcon: Icon(Icons.map_rounded, size: 20),
                                      label: Text('Map'),
                                    ),
                                    NavigationRailDestination(
                                      icon: Badge(
                                        isLabelVisible: totalUnread > 0,
                                        label: Text(totalUnread.toString()),
                                        child: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                                      ),
                                      selectedIcon: Badge(
                                        isLabelVisible: totalUnread > 0,
                                        label: Text(totalUnread.toString()),
                                        child: const Icon(Icons.chat_bubble_rounded, size: 20),
                                      ),
                                      label: const Text('Messages'),
                                    ),
                                    const NavigationRailDestination(
                                      icon: Icon(Icons.auto_awesome_outlined, size: 20),
                                      selectedIcon: Icon(Icons.auto_awesome_rounded, size: 20),
                                      label: Text('AI'),
                                    ),
                                    const NavigationRailDestination(
                                      icon: Icon(Icons.person_outline_rounded, size: 20),
                                      selectedIcon: Icon(Icons.person_rounded, size: 20),
                                      label: Text('Profile'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            VerticalDivider(width: 1, color: colorScheme.outlineVariant),
                            Expanded(
                              child: IndexedStack(
                                index: _currentIndex,
                                children: _destinations,
                              ),
                            ),
                          ],
                        )
                      : IndexedStack(
                          index: _currentIndex,
                          children: _destinations,
                        ),
                ),
              ],
            ),

            // Live Performance HUD Pill (optional overlay)
            const LatencyHudPill(),
          ],
        ),

        // Bottom Navigation Bar in Portrait
        bottomNavigationBar: isLandscape
            ? null
            : NavigationBar(
                selectedIndex: _currentIndex,
                backgroundColor: colorScheme.surfaceContainer,
                indicatorColor: colorScheme.primaryContainer,
                elevation: 0,
                height: 64,
                onDestinationSelected: setDestination,
                destinations: [
                  const NavigationDestination(
                    icon: Icon(Icons.play_circle_outline_rounded),
                    selectedIcon: Icon(Icons.play_circle_rounded),
                    label: 'Feed',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.map_outlined),
                    selectedIcon: Icon(Icons.map_rounded),
                    label: 'Map',
                  ),
                  NavigationDestination(
                    icon: Badge(
                      isLabelVisible: totalUnread > 0,
                      label: Text(totalUnread.toString()),
                      child: const Icon(Icons.chat_bubble_outline_rounded),
                    ),
                    selectedIcon: Badge(
                      isLabelVisible: totalUnread > 0,
                      label: Text(totalUnread.toString()),
                      child: const Icon(Icons.chat_bubble_rounded),
                    ),
                    label: 'Messages',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.auto_awesome_outlined),
                    selectedIcon: Icon(Icons.auto_awesome_rounded),
                    label: 'Concierge',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: 'Profile',
                  ),
                ],
              ),
      ),
    );
  }
}
