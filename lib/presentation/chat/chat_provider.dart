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
  final Map<String, EscrowDispute> _disputesCache = {};

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
        .where(
          (c) =>
              c.participantName.toLowerCase().contains(q) ||
              c.role.toLowerCase().contains(q) ||
              c.lastMessage.toLowerCase().contains(q),
        )
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
            final dispute = await repository.getDisputeForContract(
              msg.contractId!,
            );
            if (dispute != null) {
              _disputesCache[msg.contractId!] = dispute;
            }
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
    _updateLastConversationMessage(
      conversationId,
      'Contract Proposal: $title',
      nowStr,
    );
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

  EscrowDispute? getDisputeForContract(String contractId) =>
      _disputesCache[contractId];

  Future<void> initiateDispute({
    required String contractId,
    required String reason,
    required String evidenceNotes,
    required double proposedRefundPercent,
  }) async {
    final contract = _contractsCache[contractId];
    if (contract == null) return;

    final disputeId = 'disp_${_uuid.v4().substring(0, 8)}';
    final dispute = EscrowDispute(
      id: disputeId,
      contractId: contractId,
      conversationId: contract.conversationId,
      claimantName: 'Safeer Hussain',
      reason: reason,
      evidenceNotes: evidenceNotes,
      claimAmount: contract.budget,
      proposedRefundPercent: proposedRefundPercent,
      status: 'OPEN',
      resolutionNotes: 'Dispute submitted to AgoraMarket Decentralized Tribunal. Escrow funds locked.',
      createdAt: DateTime.now().toIso8601String(),
    );

    _disputesCache[contractId] = dispute;
    _contractsCache[contractId] = contract.copyWith(status: 'DISPUTED');
    notifyListeners();

    await repository.submitDispute(dispute);

    if (_activeConversationId != null) {
      final nowStr = 'Just now';
      final refundAmount = (contract.budget * (proposedRefundPercent / 100.0))
          .toStringAsFixed(0);
      final disputeMsg = ChatMessage(
        id: 'msg_${_uuid.v4()}',
        conversationId: _activeConversationId!,
        senderId: 'system',
        senderName: 'AgoraMarket Tribunal',
        text:
            'Escrow Dispute Initiated for "${contract.title}". Reason: "$reason". Proposed resolution: \$$refundAmount (${proposedRefundPercent.toStringAsFixed(0)}%) refund. Milestone payout frozen until arbitration completes.',
        timestamp: nowStr,
        isContract: false,
      );
      _messages.add(disputeMsg);
      _updateLastConversationMessage(
        _activeConversationId!,
        'Tribunal: Dispute Opened ($reason)',
        nowStr,
      );
      notifyListeners();
      await repository.sendMessage(disputeMsg);
    }
  }

  Future<void> resolveDispute({
    required String contractId,
    required String resolutionStatus,
    required String resolutionNotes,
  }) async {
    final dispute = _disputesCache[contractId];
    final contract = _contractsCache[contractId];
    if (dispute == null || contract == null) return;

    final nowStr = DateTime.now().toIso8601String();
    final updatedDispute = dispute.copyWith(
      status: resolutionStatus,
      resolutionNotes: resolutionNotes,
      resolvedAt: nowStr,
    );

    _disputesCache[contractId] = updatedDispute;
    _contractsCache[contractId] = contract.copyWith(status: 'RESOLVED');
    notifyListeners();

    await repository.resolveDispute(
      disputeId: dispute.id,
      contractId: contractId,
      resolutionStatus: resolutionStatus,
      resolutionNotes: resolutionNotes,
    );

    if (_activeConversationId != null) {
      final resolutionSummary = resolutionStatus == 'RESOLVED_SPLIT'
          ? '50/50 Mutual Compromise Settlement'
          : resolutionStatus == 'RESOLVED_REFUND'
          ? '100% Full Refund Issued to Client'
          : '100% Milestone Release Paid to Talent';

      final resolutionMsg = ChatMessage(
        id: 'msg_${_uuid.v4()}',
        conversationId: _activeConversationId!,
        senderId: 'system',
        senderName: 'AgoraMarket Tribunal',
        text:
            'Arbitration Ruling Issued for "${contract.title}": $resolutionSummary. Notes: $resolutionNotes. Escrow disbursed according to protocol ruling.',
        timestamp: 'Just now',
        isContract: false,
      );
      _messages.add(resolutionMsg);
      _updateLastConversationMessage(
        _activeConversationId!,
        'Tribunal Ruling: $resolutionSummary',
        'Just now',
      );
      notifyListeners();
      await repository.sendMessage(resolutionMsg);
    }
  }

  void _updateLastConversationMessage(
    String conversationId,
    String text,
    String time,
  ) {
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

        final replyText =
            'Acknowledged. Reviewing the contract requirements and schedule now.';
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
