import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/database/app_database.dart';
import '../../core/di/injection_container.dart';
import '../../core/performance/render_latency_monitor.dart';
import '../navigation/adaptive_scaffold.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  String _statusText = 'Initializing sub-second frame pre-cache..';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeIn));

    _animController.forward();

    // Defer boot sequence to post-frame callback ensuring the Flutter engine mounts UI first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _runBootSequence();
      }
    });
  }

  Future<void> _runBootSequence() async {
    if (!mounted) return;

    try {
      // 1. Initialize RenderLatencyMonitor timing callbacks after first frame mounts
      try {
        final monitor = Provider.of<RenderLatencyMonitor>(
          context,
          listen: false,
        );
        monitor.initialize();
      } catch (e) {
        debugPrint('RenderLatencyMonitor initialize warning: $e');
      }

      // 2. Safe asset pre-caching with error handling
      if (!mounted) return;
      try {
        final monitor = Provider.of<RenderLatencyMonitor>(
          context,
          listen: false,
        );
        await monitor.preCacheFeedAssets(context);
      } catch (e) {
        debugPrint('Asset pre-cache warning: $e');
      }

      // 3. Warm up SQLite database and verify spatial indices
      if (!mounted) return;
      setState(() {
        _statusText = 'Mounting SQLite messaging & spatial index...';
      });

      try {
        if (sl.isRegistered<AppDatabase>()) {
          await sl<AppDatabase>().database;
        }
      } catch (e) {
        debugPrint('Database warmup warning: $e');
      }

      await Future.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;

      setState(() {
        _statusText = 'AgoraMarket Ready.';
      });

      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const AdaptiveScaffold(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } catch (e, stack) {
      debugPrint('Startup sequence warning: $e\n$stack');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdaptiveScaffold()),
        );
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: colorScheme.outlineVariant,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.25),
                            blurRadius: 32,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Image.asset(
                        'assets/icons/app_icon.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'AgoraMarket',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Vertical Video Job & Service Engine',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: 160,
                      child: LinearProgressIndicator(
                        backgroundColor: colorScheme.surfaceContainerHigh,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
                        ),
                        minHeight: 2.5,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 14),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _statusText,
                        key: ValueKey<String>(_statusText),
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
