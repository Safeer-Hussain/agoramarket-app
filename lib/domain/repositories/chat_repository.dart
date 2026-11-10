import '../entities/chat_entities.dart';

abstract class ChatRepository {
  Future<List<ChatConversation>> getConversations();
  Future<List<ChatMessage>> getMessages(String conversationId);
  Future<void> sendMessage(ChatMessage message);
  Future<ContractOffer?> getContractOffer(String contractId);
  Future<void> createContractOffer(ContractOffer offer);
  Future<void> updateContractStatus(String contractId, String status);
  Future<void> submitDispute(EscrowDispute dispute);
  Future<EscrowDispute?> getDisputeForContract(String contractId);
  Future<void> resolveDispute({
    required String disputeId,
    required String contractId,
    required String resolutionStatus,
    required String resolutionNotes,
  });
}
