import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/database/app_database.dart';
import '../../core/performance/render_latency_monitor.dart';
import '../../core/utils/app_feedback.dart';
import '../chat/chat_provider.dart';
import '../feed/video_feed_provider.dart';
import '../profile/profile_provider.dart';

class RecruiterDebugDrawer extends StatefulWidget {
  const RecruiterDebugDrawer({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const RecruiterDebugDrawer(),
    );
  }

  @override
  State<RecruiterDebugDrawer> createState() => _RecruiterDebugDrawerState();
}

class _RecruiterDebugDrawerState extends State<RecruiterDebugDrawer> {
  double _latency = 500.0;
  bool _force503 = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _latency = (prefs.getInt(AppConstants.prefSimulatedLatency) ?? 500)
          .toDouble();
      _force503 = prefs.getBool(AppConstants.prefForce503) ?? false;
    });
  }

  Future<void> _setLatency(double val) async {
    if (!mounted) return;
    setState(() {
      _latency = val;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.prefSimulatedLatency, val.round());
  }

  Future<void> _toggle503(bool val) async {
    if (!mounted) return;
    setState(() {
      _force503 = val;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefForce503, val);
  }

  Future<void> _resetDatabase() async {
    final feed = Provider.of<VideoFeedProvider>(context, listen: false);
    final profile = Provider.of<ProfileProvider>(context, listen: false);
    final chat = Provider.of<ChatProvider>(context, listen: false);

    await AppDatabase().resetDatabase();
    await feed.loadPitches();
    await profile.loadProfileData();
    await chat.loadConversations();

    if (!mounted) return;
    AppFeedback.showSuccess(context, 'SQLite tables reset to seed state');
  }

  void _simulateIncomingChat() {
    final chat = Provider.of<ChatProvider>(context, listen: false);
    chat.sendTextMessage(
      'Simulated recruiter ping: Urgent contract role open for Senior Architect',
    );
    AppFeedback.showInfo(context, 'Simulated incoming message queued');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final monitor = Provider.of<RenderLatencyMonitor>(context);

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SingleChildScrollView(
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
                children: [
                  Icon(
                    Icons.developer_mode_rounded,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Recruiter & Senior Architect Debug Console',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Live fault injection, performance telemetry, and local SQLite state controls.',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),

              // HUD Pill Toggle
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Display Frame Latency HUD Pill',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Sub-8ms 120 FPS live overlay in top-right corner',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                value: monitor.showHudPill,
                activeThumbColor: colorScheme.primary,
                onChanged: (_) => monitor.toggleHudPill(),
              ),
              const Divider(height: 20),

              // Simulated Latency
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Simulated Network Latency',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '${_latency.round()} ms',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _latency,
                min: 100.0,
                max: 2000.0,
                activeColor: colorScheme.secondary,
                inactiveColor: colorScheme.surfaceContainerHighest,
                onChanged: _setLatency,
              ),
              const Divider(height: 20),

              // Force HTTP 503 Fault Injection
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Inject HTTP 503 Service Unavailable',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Tests offline resilient UI fallbacks and error banners',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                value: _force503,
                activeThumbColor: colorScheme.error,
                onChanged: _toggle503,
              ),
              const Divider(height: 20),

              // Trigger Simulated Message
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.mark_chat_unread_outlined,
                  color: colorScheme.primary,
                ),
                title: Text(
                  'Simulate Inbound Recruiter Proposal',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Queues simulated incoming message into active chat thread',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: FilledButton.tonal(
                  onPressed: _simulateIncomingChat,
                  child: const Text('Trigger', style: TextStyle(fontSize: 12)),
                ),
              ),
              const Divider(height: 20),

              // Reset SQLite Database
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.restore_page_outlined,
                  color: colorScheme.error,
                ),
                title: Text(
                  'Reset SQLite Marketplace Database',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Flushes tables and restores original seed data',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                  ),
                  onPressed: _resetDatabase,
                  child: const Text('Reset DB', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
