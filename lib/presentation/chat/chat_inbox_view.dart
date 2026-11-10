import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/app_feedback.dart';
import '../../domain/entities/chat_entities.dart';
import 'chat_provider.dart';
import 'chat_conversation_view.dart';

class ChatInboxView extends StatefulWidget {
  const ChatInboxView({super.key});

  @override
  State<ChatInboxView> createState() => _ChatInboxViewState();
}

class _ChatInboxViewState extends State<ChatInboxView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showNewChatDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: colorScheme.surfaceContainer,
        title: Text(
          'Start Direct Technical Thread',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildContactTile(
              name: 'Dr. Tariq Mahmood',
              role: 'Fintech Engineering Director',
              avatar: 'assets/images/avatar_bilal.png',
              onTap: () {
                Navigator.of(dialogCtx).pop();
                chatProvider.createNewConversation(
                  name: 'Dr. Tariq Mahmood',
                  role: 'Fintech Engineering Director',
                  avatar: 'assets/images/avatar_bilal.png',
                );
                AppFeedback.showSuccess(
                  context,
                  'Direct negotiation channel initialized',
                );
              },
            ),
            const SizedBox(height: 8),
            _buildContactTile(
              name: 'Sarah Jenkins',
              role: 'VP Product at Nexus Global',
              avatar: 'assets/images/avatar_zoya.png',
              onTap: () {
                Navigator.of(dialogCtx).pop();
                chatProvider.createNewConversation(
                  name: 'Sarah Jenkins',
                  role: 'VP Product at Nexus Global',
                  avatar: 'assets/images/avatar_zoya.png',
                );
                AppFeedback.showSuccess(
                  context,
                  'Direct negotiation channel initialized',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile({
    required String name,
    required String role,
    required String avatar,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: CircleAvatar(radius: 18, backgroundImage: AssetImage(avatar)),
      title: Text(
        name,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        role,
        style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final convos = chatProvider.conversations;
        final activeConv = chatProvider.activeConversation;

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            title: Text(
              'Negotiation Hub',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            toolbarHeight: isLandscape ? 36 : 56,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(isLandscape ? 40 : 54),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search conversations & contracts...',
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: 18,
                      color: colorScheme.outline,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (q) => chatProvider.setSearchFilter(q),
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'fab_chat_new',
            tooltip: 'Start new direct contract negotiation',
            mini: isLandscape,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            onPressed: () => _showNewChatDialog(context),
            child: const Icon(Icons.edit_note_rounded),
          ),
          body: isLandscape
              ? _buildLandscapeLayout(context, chatProvider, convos, activeConv)
              : _buildPortraitLayout(context, chatProvider, convos),
        );
      },
    );
  }

  Widget _buildPortraitLayout(
    BuildContext context,
    ChatProvider chatProvider,
    List<ChatConversation> convos,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    if (convos.isEmpty) {
      return Center(
        child: Text(
          'No conversations found.',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: convos.length,
      separatorBuilder: (_, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final conv = convos[index];
        return _buildConversationCard(
          context: context,
          conversation: conv,
          isSelected: false,
          onTap: () {
            chatProvider.selectConversation(conv.id);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatConversationView(conversation: conv),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    ChatProvider chatProvider,
    List<ChatConversation> convos,
    ChatConversation? activeConv,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        // Left Pane: Conversation List
        Expanded(
          flex: 4,
          child: Container(
            color: colorScheme.surfaceContainerLowest,
            child: convos.isEmpty
                ? Center(
                    child: Text(
                      'No conversations found.',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  )
                : ListView.separated(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: convos.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final conv = convos[index];
                      final isSelected = conv.id == activeConv?.id;
                      return _buildConversationCard(
                        context: context,
                        conversation: conv,
                        isSelected: isSelected,
                        onTap: () {
                          chatProvider.selectConversation(conv.id);
                        },
                      );
                    },
                  ),
          ),
        ),

        // Vertical divider
        VerticalDivider(width: 1, color: colorScheme.outlineVariant),

        // Right Pane: Active Chat Thread
        Expanded(
          flex: 6,
          child: activeConv != null
              ? ChatConversationView(conversation: activeConv, isPane: true)
              : Center(
                  child: Text(
                    'Select a thread to view messages and contract milestones.',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildConversationCard({
    required BuildContext context,
    required ChatConversation conversation,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label:
          'Conversation with ${conversation.participantName}, ${conversation.role}. Last message: ${conversation.lastMessage}. ${conversation.unreadCount > 0 ? "${conversation.unreadCount} unread" : "All read"}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.surfaceContainerHigh
                  : colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      backgroundImage: AssetImage(
                        conversation.participantAvatar,
                      ),
                    ),
                    if (conversation.isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.surface,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.participantName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            conversation.lastMessageTime,
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        conversation.role,
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          if (conversation.unreadCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.secondary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                conversation.unreadCount.toString(),
                                style: TextStyle(
                                  color: colorScheme.onSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
