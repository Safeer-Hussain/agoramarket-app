class ChatConversation {
  final String id;
  final String participantName;
  final String participantAvatar;
  final String role;
  final String lastMessage;
  final String lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  const ChatConversation({
    required this.id,
    required this.participantName,
    required this.participantAvatar,
    required this.role,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isOnline,
  });

  ChatConversation copyWith({
    String? id,
    String? participantName,
    String? participantAvatar,
    String? role,
    String? lastMessage,
    String? lastMessageTime,
    int? unreadCount,
    bool? isOnline,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      participantName: participantName ?? this.participantName,
      participantAvatar: participantAvatar ?? this.participantAvatar,
      role: role ?? this.role,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participant_name': participantName,
      'participant_avatar': participantAvatar,
      'role': role,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime,
      'unread_count': unreadCount,
      'is_online': isOnline ? 1 : 0,
    };
  }

  factory ChatConversation.fromMap(Map<String, dynamic> map) {
    return ChatConversation(
      id: map['id'] as String,
      participantName: map['participant_name'] as String,
      participantAvatar: map['participant_avatar'] as String,
      role: map['role'] as String,
      lastMessage: map['last_message'] as String,
      lastMessageTime: map['last_message_time'] as String,
      unreadCount: map['unread_count'] as int,
      isOnline: (map['is_online'] as int) == 1,
    );
  }
}

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String text;
  final String timestamp;
  final bool isContract;
  final String? contractId;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    required this.isContract,
    this.contractId,
  });

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? text,
    String? timestamp,
    bool? isContract,
    String? contractId,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isContract: isContract ?? this.isContract,
      contractId: contractId ?? this.contractId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'sender_name': senderName,
      'text': text,
      'timestamp': timestamp,
      'is_contract': isContract ? 1 : 0,
      'contract_id': contractId,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String,
      conversationId: map['conversation_id'] as String,
      senderId: map['sender_id'] as String,
      senderName: map['sender_name'] as String,
      text: map['text'] as String,
      timestamp: map['timestamp'] as String,
      isContract: (map['is_contract'] as int) == 1,
      contractId: map['contract_id'] as String?,
    );
  }
}

class ContractOffer {
  final String id;
  final String conversationId;
  final String title;
  final double budget;
  final String currency;
  final int deliveryDays;
  final String status; // 'PENDING', 'ACCEPTED', 'COUNTERED', 'DECLINED'
  final String terms;
  final String createdAt;

  const ContractOffer({
    required this.id,
    required this.conversationId,
    required this.title,
    required this.budget,
    required this.currency,
    required this.deliveryDays,
    required this.status,
    required this.terms,
    required this.createdAt,
  });

  ContractOffer copyWith({
    String? id,
    String? conversationId,
    String? title,
    double? budget,
    String? currency,
    int? deliveryDays,
    String? status,
    String? terms,
    String? createdAt,
  }) {
    return ContractOffer(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      title: title ?? this.title,
      budget: budget ?? this.budget,
      currency: currency ?? this.currency,
      deliveryDays: deliveryDays ?? this.deliveryDays,
      status: status ?? this.status,
      terms: terms ?? this.terms,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'title': title,
      'budget': budget,
      'currency': currency,
      'delivery_days': deliveryDays,
      'status': status,
      'terms': terms,
      'created_at': createdAt,
    };
  }

  factory ContractOffer.fromMap(Map<String, dynamic> map) {
    return ContractOffer(
      id: map['id'] as String,
      conversationId: map['conversation_id'] as String,
      title: map['title'] as String,
      budget: (map['budget'] as num).toDouble(),
      currency: map['currency'] as String,
      deliveryDays: map['delivery_days'] as int,
      status: map['status'] as String,
      terms: map['terms'] as String,
      createdAt: map['created_at'] as String,
    );
  }
}

class EscrowDispute {
  final String id;
  final String contractId;
  final String conversationId;
  final String claimantName;
  final String reason;
  final String evidenceNotes;
  final double claimAmount;
  final double proposedRefundPercent; // 0.0 to 100.0
  final String
  status; // 'OPEN', 'RESOLVED_SPLIT', 'RESOLVED_REFUND', 'RESOLVED_PAYOUT'
  final String resolutionNotes;
  final String createdAt;
  final String? resolvedAt;

  const EscrowDispute({
    required this.id,
    required this.contractId,
    required this.conversationId,
    required this.claimantName,
    required this.reason,
    required this.evidenceNotes,
    required this.claimAmount,
    required this.proposedRefundPercent,
    required this.status,
    required this.resolutionNotes,
    required this.createdAt,
    this.resolvedAt,
  });

  EscrowDispute copyWith({
    String? id,
    String? contractId,
    String? conversationId,
    String? claimantName,
    String? reason,
    String? evidenceNotes,
    double? claimAmount,
    double? proposedRefundPercent,
    String? status,
    String? resolutionNotes,
    String? createdAt,
    String? resolvedAt,
  }) {
    return EscrowDispute(
      id: id ?? this.id,
      contractId: contractId ?? this.contractId,
      conversationId: conversationId ?? this.conversationId,
      claimantName: claimantName ?? this.claimantName,
      reason: reason ?? this.reason,
      evidenceNotes: evidenceNotes ?? this.evidenceNotes,
      claimAmount: claimAmount ?? this.claimAmount,
      proposedRefundPercent:
          proposedRefundPercent ?? this.proposedRefundPercent,
      status: status ?? this.status,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contract_id': contractId,
      'conversation_id': conversationId,
      'claimant_name': claimantName,
      'reason': reason,
      'evidence_notes': evidenceNotes,
      'claim_amount': claimAmount,
      'proposed_refund_percent': proposedRefundPercent,
      'status': status,
      'resolution_notes': resolutionNotes,
      'created_at': createdAt,
      'resolved_at': resolvedAt,
    };
  }

  factory EscrowDispute.fromMap(Map<String, dynamic> map) {
    return EscrowDispute(
      id: map['id'] as String,
      contractId: map['contract_id'] as String,
      conversationId: map['conversation_id'] as String,
      claimantName: map['claimant_name'] as String,
      reason: map['reason'] as String,
      evidenceNotes: map['evidence_notes'] as String,
      claimAmount: (map['claim_amount'] as num).toDouble(),
      proposedRefundPercent: (map['proposed_refund_percent'] as num).toDouble(),
      status: map['status'] as String,
      resolutionNotes: map['resolution_notes'] as String,
      createdAt: map['created_at'] as String,
      resolvedAt: map['resolved_at'] as String?,
    );
  }
}
