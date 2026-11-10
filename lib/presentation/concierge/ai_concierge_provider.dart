import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/database/app_database.dart';

class ConciergeMessage {
  final String id;
  final String text;
  final bool isUser;
  final String timestamp;
  final String? reasoning;

  ConciergeMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.reasoning,
  });
}

class AiConciergeProvider extends ChangeNotifier {
  final AppDatabase _database;

  final List<ConciergeMessage> _messages = [];
  bool _isLoading = false;
  String? _reasoningText;
  String _currentStreamingText = '';
  bool _disposed = false;

  AiConciergeProvider({AppDatabase? database}) : _database = database ?? AppDatabase() {
    _initWelcome();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  List<ConciergeMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get reasoningText => _reasoningText;
  String get currentStreamingText => _currentStreamingText;

  void _initWelcome() {
    _messages.add(
      ConciergeMessage(
        id: 'msg_welcome',
        text:
            'Welcome to the AgoraMarket Smart Concierge. I analyze your SQLite marketplace pitches, active contracts, and local Lahore / remote rates in real-time.\n\nTap a quick shortcut below or ask any technical consultation question.',
        isUser: false,
        timestamp: 'Ready',
      ),
    );
  }

  Future<void> submitQuery(String query) async {
    if (query.trim().isEmpty || _isLoading) return;

    final userMsgId = 'usr_${DateTime.now().millisecondsSinceEpoch}';
    _messages.add(
      ConciergeMessage(
        id: userMsgId,
        text: query.trim(),
        isUser: true,
        timestamp: 'Just now',
      ),
    );
    notifyListeners();

    _isLoading = true;
    _reasoningText = 'Evaluating local market rates & video engagement telemetry...';
    _currentStreamingText = '';
    notifyListeners();

    try {
      final db = await _database.database;
      final pitches = await db.query('video_pitches');
      final contracts = await db.query('contract_offers');

      await Future.delayed(const Duration(milliseconds: 650));
      if (_disposed) return;
      _reasoningText = 'Synthesizing benchmark telemetry across ${pitches.length} marketplace listings and ${contracts.length} escrow contracts...';
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 550));
      if (_disposed) return;
      _reasoningText = null;

      final fullResponse = _generateResponse(query, pitches, contracts);

      final words = fullResponse.split(' ');
      for (int i = 0; i < words.length; i++) {
        if (_disposed) return;
        _currentStreamingText += (i == 0 ? '' : ' ') + words[i];
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 28));
      }

      _messages.add(
        ConciergeMessage(
          id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
          text: _currentStreamingText,
          isUser: false,
          timestamp: 'Just now',
        ),
      );
      _currentStreamingText = '';
    } finally {
      _isLoading = false;
      _reasoningText = null;
      notifyListeners();
    }
  }

  String _generateResponse(
    String query,
    List<Map<String, dynamic>> pitches,
    List<Map<String, dynamic>> contracts,
  ) {
    final q = query.toLowerCase();

    if (q.contains('optimize') || q.contains('pitch script')) {
      return 'Analysis of your vertical video pitches shows that scripts opening with a quantifiable technical metric (such as "Sub-8ms frame time" or "Zero-downtime failover") achieve 2.4x higher contract conversion than traditional portfolio summaries.\n\nRecommended Structure:\n1. Hook (0-5s): State exact engineering latency or throughput achieved.\n2. Architecture (5-30s): Walk through the SQLite schema / Custom Canvas rendering tree.\n3. Call-to-Action (30-45s): Direct clients to dispatch a milestone escrow offer directly in-app.';
    }

    if (q.contains('compare') || q.contains('rate') || q.contains('market')) {
      return 'Marketplace Benchmark Analysis:\n- Your Profile Base: \$95.00/hr (USD) ~ PKR 26,450/hr\n- Lahore Gulberg/DHA Senior Flutter Median: \$65.00 - \$85.00/hr\n- US/EU Remote Principal Architecture Median: \$90.00 - \$120.00/hr\n\nVerdict: Your current rate of \$95/hr sits at the top 8th percentile of regional talent, but matches global remote enterprise contracts perfectly given your 120 FPS custom canvas and sub-second caching specializations.';
    }

    if (q.contains('counter') || q.contains('offer') || q.contains('contract')) {
      return 'Recommended Counter-Offer Template:\n"Thank you for the project proposal. Reviewing the 14-day timeline against our performance acceptance tests (sub-8ms frame latency and full SQLite indexing), we can deliver under two milestone phases:\n- Milestone 1 (\$2,200): Core Engine & Local Spatial Index (7 Days)\n- Milestone 2 (\$1,800): Real-Time Negotiation Protocol & CI/CD Pipeline (7 Days)\n\nThis safeguards deliverable quality with zero schedule slippage."';
    }

    if (q.contains('match') || q.contains('jobs') || q.contains('top 3')) {
      return 'Top 3 Recommended Matches From Local Spatial Index:\n\n1. Enterprise LLM Agents & Deterministic Tooling (Johar Town, Lahore)\n- Rate: \$110/hr • Match Score: 98%\n- Synergy: Integrates directly with your on-device local database.\n\n2. Design Systems Overhaul for Hyper-Growth Fintech (DHA Phase 5, Lahore)\n- Rate: \$75/hr • Match Score: 94%\n- Synergy: High-performance Flutter component library.\n\n3. Zero-Downtime Multi-Region Kubernetes (Arfa Software Park, Lahore)\n- Rate: \$85/hr • Match Score: 91%\n- Synergy: Cloud-native backend integration.';
    }

    return 'AgoraMarket Concierge evaluated your query against active SQLite indices:\n- Found ${pitches.length} verified listings in Gulberg, DHA, and Johar Town.\n- Active escrow proposals indexed: ${contracts.length}.\n\nYour profile telemetry reflects 120 FPS render capability and verified identity. To initiate new contracts, tap "+ Publish Video Pitch" or select any map pin to message direct.';
  }
}
