import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ai_concierge_provider.dart';

class AiMatchConciergeView extends StatefulWidget {
  const AiMatchConciergeView({super.key});

  @override
  State<AiMatchConciergeView> createState() => _AiMatchConciergeViewState();
}

class _AiMatchConciergeViewState extends State<AiMatchConciergeView> {
  final TextEditingController _queryController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const List<String> _shortcuts = [
    'Optimize My Video Pitch Script',
    'Compare My Rate to Local Lahore/Remote Market',
    'Draft Counter-Offer Message',
    'Match Me With Top 3 Video Jobs',
  ];

  @override
  void dispose() {
    _queryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _submit(String text) {
    if (text.trim().isEmpty) return;
    final concierge = Provider.of<AiConciergeProvider>(context, listen: false);
    concierge.submitQuery(text);
    _queryController.clear();

    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Consumer<AiConciergeProvider>(
      builder: (context, concierge, child) {
        return Scaffold(
          backgroundColor: colorScheme.surface,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            toolbarHeight: isLandscape ? 36 : 56,
            title: Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Smart Concierge & Pitch Analyzer',
                  style: TextStyle(
                    fontSize: isLandscape ? 13 : 16,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          body: isLandscape
              ? _buildLandscapeLayout(context, concierge)
              : _buildPortraitLayout(context, concierge),
        );
      },
    );
  }

  Widget _buildPortraitLayout(
    BuildContext context,
    AiConciergeProvider concierge,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Quick Shortcuts Carousel
        Container(
          height: 48,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _shortcuts.length,
            separatorBuilder: (_, index) => const SizedBox(width: 8),
            itemBuilder: (context, idx) {
              final shortcut = _shortcuts[idx];
              return ActionChip(
                backgroundColor: colorScheme.surfaceContainerHigh,
                side: BorderSide(color: colorScheme.outlineVariant),
                label: Text(
                  shortcut,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                onPressed: concierge.isLoading ? null : () => _submit(shortcut),
              );
            },
          ),
        ),
        const Divider(height: 1),

        // Chat stream & reasoning
        Expanded(child: _buildMessagesList(context, concierge)),

        // Bottom Input Bar
        _buildBottomInputBar(context, concierge),
      ],
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    AiConciergeProvider concierge,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        // Left Pane: Shortcuts & Telemetry Info (independent SingleChildScrollView)
        Expanded(
          flex: 4,
          child: Container(
            color: colorScheme.surfaceContainerLowest,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Marketplace Shortcuts',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._shortcuts.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: InkWell(
                        onTap: concierge.isLoading ? null : () => _submit(s),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          child: Text(
                            s,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.memory_rounded,
                              size: 14,
                              color: colorScheme.secondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'On-Device Synthesis',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Queries analyze local SQLite pitches, Lahore hub coordinates, and escrow contract status without external server costs.',
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.onSurfaceVariant,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Vertical Divider
        VerticalDivider(width: 1, color: colorScheme.outlineVariant),

        // Right Pane: Messages Stream & Docked Input Bar
        Expanded(
          flex: 6,
          child: Column(
            children: [
              Expanded(child: _buildMessagesList(context, concierge)),
              _buildBottomInputBar(context, concierge),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessagesList(
    BuildContext context,
    AiConciergeProvider concierge,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      controller: _scrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount:
          concierge.messages.length +
          (concierge.reasoningText != null ? 1 : 0) +
          (concierge.currentStreamingText.isNotEmpty ? 1 : 0),
      itemBuilder: (context, idx) {
        if (idx < concierge.messages.length) {
          final msg = concierge.messages[idx];
          return _buildMessageBubble(context, msg);
        }

        // Active Reasoning Indicator
        if (concierge.reasoningText != null &&
            idx == concierge.messages.length) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    concierge.reasoningText!,
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Streaming text bubble
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Text(
            concierge.currentStreamingText,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface,
              height: 1.4,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(BuildContext context, ConciergeMessage msg) {
    final colorScheme = Theme.of(context).colorScheme;
    final isUser = msg.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUser
                ? colorScheme.primary.withValues(alpha: 0.3)
                : colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'AgoraMarket Intelligence',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              msg.text,
              style: TextStyle(
                color: isUser
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              msg.timestamp,
              style: TextStyle(
                fontSize: 9,
                color:
                    (isUser
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant)
                        .withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomInputBar(
    BuildContext context,
    AiConciergeProvider concierge,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _queryController,
                style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
                decoration: InputDecoration(
                  hintText:
                      'Ask concierge about rates, pitch scripts, or jobs...',
                  hintStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHigh,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: colorScheme.primary),
                  ),
                ),
                onSubmitted: (t) => _submit(t),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: 'Send prompt to AI marketplace concierge',
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              onPressed: concierge.isLoading
                  ? null
                  : () => _submit(_queryController.text),
              icon: const Icon(Icons.arrow_upward_rounded, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
