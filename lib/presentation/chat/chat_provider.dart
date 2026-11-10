import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/chat_entities.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository repository;
  final Uuid _uuid = const Uuid();

  List<ChatConversation> _conversations = [];
  String? _activeConversationId;
  List<ChatMessage> _messages = [];
  final Map<String, ContractOffer> _contractsCache = {};

  bool _isLoading = false;
  bool _isTyping = false;
  String _searchFilter = '';
  Timer? _peerReplyTimer;
  bool _disposed = false;

  ChatProvider({required this.repository}) {
    loadConversations();
  }

  @override
  void dispose() {
    _disposed = true;
    _peerReplyTimer?.cancel();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  List<ChatConversation> get conversations {
    if (_searchFilter.trim().isEmpty) return _conversations;
    final q = _searchFilter.toLowerCase();
    return _conversations
        .where((c) =>
            c.participantName.toLowerCase().contains(q) ||
            c.role.toLowerCase().contains(q) ||
            c.lastMessage.toLowerCase().contains(q))
        .toList();
  }

  String? get activeConversationId => _activeConversationId;
  ChatConversation? get activeConversation {
    if (_activeConversationId == null) return null;
    final idx = _conversations.indexWhere((c) => c.id == _activeConversationId);
    return idx != -1 ? _conversations[idx] : null;
  }

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;
  String get searchFilter => _searchFilter;

  ContractOffer? getContractOffer(String? contractId) {
    if (contractId == null) return null;
    return _contractsCache[contractId];
  }

  void setSearchFilter(String filter) {
    _searchFilter = filter;
    notifyListeners();
  }

  Future<void> loadConversations() async {
    _isLoading = true;
    notifyListeners();

    try {
      _conversations = await repository.getConversations();
      if (_conversations.isNotEmpty && _activeConversationId == null) {
        _activeConversationId = _conversations.first.id;
      }
      if (_activeConversationId != null) {
        await selectConversation(_activeConversationId!);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectConversation(String conversationId) async {
    _activeConversationId = conversationId;
    _isLoading = true;
    notifyListeners();

    try {
      _messages = await repository.getMessages(conversationId);
      for (final msg in _messages) {
        if (msg.isContract && msg.contractId != null) {
          final offer = await repository.getContractOffer(msg.contractId!);
          if (offer != null) {
            _contractsCache[msg.contractId!] = offer;
          }
        }
      }

      final idx = _conversations.indexWhere((c) => c.id == conversationId);
      if (idx != -1 && _conversations[idx].unreadCount > 0) {
        _conversations[idx] = _conversations[idx].copyWith(unreadCount: 0);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendTextMessage(String text) async {
    if (text.trim().isEmpty || _activeConversationId == null) return;

    final nowStr = 'Just now';
    final newMsg = ChatMessage(
      id: 'msg_${_uuid.v4()}',
      conversationId: _activeConversationId!,
      senderId: 'safeer',
      senderName: 'Safeer Hussain',
      text: text.trim(),
      timestamp: nowStr,
      isContract: false,
    );

    _messages.add(newMsg);
    _updateLastConversationMessage(_activeConversationId!, text.trim(), nowStr);
    notifyListeners();

    await repository.sendMessage(newMsg);

    _simulatePeerReply(_activeConversationId!);
  }

  Future<void> sendContractOffer({
    required String conversationId,
    required String title,
    required double budget,
    required String currency,
    required int deliveryDays,
    required String terms,
  }) async {
    final contractId = 'contract_${_uuid.v4()}';
    final offer = ContractOffer(
      id: contractId,
      conversationId: conversationId,
      title: title,
      budget: budget,
      currency: currency,
      deliveryDays: deliveryDays,
      status: 'PENDING',
      terms: terms,
      createdAt: DateTime.now().toIso8601String(),
    );

    _contractsCache[contractId] = offer;
    await repository.createContractOffer(offer);

    final nowStr = 'Just now';
    final newMsg = ChatMessage(
      id: 'msg_${_uuid.v4()}',
      conversationId: conversationId,
      senderId: 'safeer',
      senderName: 'Safeer Hussain',
      text: 'Sent Project Contract Proposal: $title',
      timestamp: nowStr,
      isContract: true,
      contractId: contractId,
    );

    if (_activeConversationId == conversationId) {
      _messages.add(newMsg);
    }
    _updateLastConversationMessage(conversationId, 'Contract Proposal: $title', nowStr);
    notifyListeners();

    await repository.sendMessage(newMsg);
  }

  Future<void> updateContractStatus(String contractId, String status) async {
    final cur = _contractsCache[contractId];
    if (cur != null) {
      _contractsCache[contractId] = cur.copyWith(status: status);
      notifyListeners();

      await repository.updateContractStatus(contractId, status);

      if (_activeConversationId != null) {
        final nowStr = 'Just now';
        final statusMsg = ChatMessage(
          id: 'msg_${_uuid.v4()}',
          conversationId: _activeConversationId!,
          senderId: 'system',
          senderName: 'AgoraMarket Protocol',
          text: 'Contract "${cur.title}" status changed to: $status',
          timestamp: nowStr,
          isContract: false,
        );
        _messages.add(statusMsg);
        notifyListeners();
        await repository.sendMessage(statusMsg);
      }
    }
  }

  void _updateLastConversationMessage(String conversationId, String text, String time) {
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx != -1) {
      _conversations[idx] = _conversations[idx].copyWith(
        lastMessage: text,
        lastMessageTime: time,
      );
    }
  }

  void _simulatePeerReply(String conversationId) {
    _isTyping = true;
    notifyListeners();

    _peerReplyTimer?.cancel();
    _peerReplyTimer = Timer(const Duration(milliseconds: 1400), () async {
      try {
        if (_activeConversationId != conversationId) return;

        final replyText = 'Acknowledged. Reviewing the contract requirements and schedule now.';
        final nowStr = 'Just now';
        final peerMsg = ChatMessage(
          id: 'msg_${_uuid.v4()}',
          conversationId: conversationId,
          senderId: 'peer',
          senderName: activeConversation?.participantName ?? 'Client',
          text: replyText,
          timestamp: nowStr,
          isContract: false,
        );

        _messages.add(peerMsg);
        _updateLastConversationMessage(conversationId, replyText, nowStr);
      } finally {
        _isTyping = false;
        notifyListeners();
      }
    });
  }

  Future<void> createNewConversation({
    required String name,
    required String role,
    required String avatar,
  }) async {
    final id = 'conv_${_uuid.v4().substring(0, 8)}';
    final newConv = ChatConversation(
      id: id,
      participantName: name,
      participantAvatar: avatar,
      role: role,
      lastMessage: 'Conversation opened',
      lastMessageTime: 'Just now',
      unreadCount: 0,
      isOnline: true,
    );

    _conversations.insert(0, newConv);
    await selectConversation(id);
    notifyListeners();
  }
}
